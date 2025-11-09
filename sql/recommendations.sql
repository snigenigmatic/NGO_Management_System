-- Recommendations helpers: fulltext indexes and example recommend procedures
-- Run this script in the ngo_management database as a privileged user.
USE ngo_management;

-- Add FULLTEXT indexes (may error if the index already exists; run once)
ALTER TABLE Sponsor_Interest ADD FULLTEXT idx_si_interest_full (interest);
ALTER TABLE Sponsor ADD FULLTEXT idx_sponsor_focus (Focus_area);
ALTER TABLE Vendor ADD FULLTEXT idx_vendor_service (Service_type);

DELIMITER $$
-- Procedure: recommend_sponsors_for_event (LIKE-based multi-word stem matching + semantic mapping)
-- Uses LIKE for broad substring matching on interests and Focus_area across all words
DROP PROCEDURE IF EXISTS recommend_sponsors_for_event$$
CREATE PROCEDURE recommend_sponsors_for_event(IN p_event_type TEXT)
BEGIN
    DECLARE input_text TEXT;
    DECLARE word VARCHAR(255);
    DECLARE stem VARCHAR(255);
    DECLARE remaining TEXT;
    DECLARE word_count INT DEFAULT 0;
    
    SET input_text = LOWER(TRIM(p_event_type));
    SET remaining = input_text;
    
    -- Create a temporary table to hold stems from all words
    DROP TEMPORARY TABLE IF EXISTS temp_sponsor_stems;
    CREATE TEMPORARY TABLE temp_sponsor_stems (stem VARCHAR(255));
    
    -- Create a temporary table for semantic focus area hints
    DROP TEMPORARY TABLE IF EXISTS temp_focus_hints;
    CREATE TEMPORARY TABLE temp_focus_hints (focus_hint VARCHAR(255));
    
    -- Extract stems from each word (up to 10 words to avoid infinite loops)
    WHILE LENGTH(remaining) > 0 AND word_count < 10 DO
        SET word_count = word_count + 1;
        
        -- Extract next word
        IF LOCATE(' ', remaining) > 0 THEN
            SET word = SUBSTRING_INDEX(remaining, ' ', 1);
            SET remaining = TRIM(SUBSTRING(remaining, LENGTH(word) + 2));
        ELSE
            SET word = remaining;
            SET remaining = '';
        END IF;
        
        -- Create stem (first 6 chars) and insert
        IF LENGTH(word) >= 3 THEN
            SET stem = LEFT(word, 6);
            INSERT INTO temp_sponsor_stems (stem) VALUES (stem);
            
            -- Semantic mappings: add focus area hints based on keywords
            IF word IN ('education', 'educational', 'school', 'student', 'teacher', 'learning', 'workshop', 'training') THEN
                INSERT INTO temp_focus_hints (focus_hint) VALUES ('educat'), ('stem'), ('teacher');
            END IF;
            IF word IN ('health', 'medical', 'clinic', 'hospital', 'checkup', 'healthcare') THEN
                INSERT INTO temp_focus_hints (focus_hint) VALUES ('health'), ('medica');
            END IF;
            IF word IN ('environment', 'green', 'tree', 'plantation', 'cleanup', 'forest', 'nature') THEN
                INSERT INTO temp_focus_hints (focus_hint) VALUES ('enviro'), ('reforest'), ('tree');
            END IF;
            IF word IN ('women', 'woman', 'female', 'gender', 'empowerment') THEN
                INSERT INTO temp_focus_hints (focus_hint) VALUES ('women'), ('empowe'), ('gender');
            END IF;
            IF word IN ('child', 'children', 'kid', 'youth', 'student') THEN
                INSERT INTO temp_focus_hints (focus_hint) VALUES ('child'), ('youth');
            END IF;
            IF word IN ('community', 'social', 'welfare', 'development') THEN
                INSERT INTO temp_focus_hints (focus_hint) VALUES ('commun'), ('social'), ('welfar');
            END IF;
        END IF;
    END WHILE;
    
    -- Return sponsors with scores based on matches (direct stem matches + semantic hints)
    SELECT
        s.Sponsor_ID,
        s.Name,
        s.Focus_area,
        GROUP_CONCAT(DISTINCT si.interest ORDER BY si.interest SEPARATOR ', ') AS interests,
        -- Score: 3 points for interest match via stem, 2 for focus_area stem match, 2 for semantic hint match
        (COALESCE(SUM(DISTINCT CASE WHEN LOWER(si.interest) LIKE CONCAT('%', ts.stem, '%') COLLATE utf8mb4_unicode_ci THEN 3 ELSE 0 END), 0)
         + COALESCE(SUM(DISTINCT CASE WHEN LOWER(s.Focus_area) LIKE CONCAT('%', ts.stem, '%') COLLATE utf8mb4_unicode_ci THEN 2 ELSE 0 END), 0)
         + COALESCE(SUM(DISTINCT CASE WHEN LOWER(si.interest) LIKE CONCAT('%', fh.focus_hint, '%') COLLATE utf8mb4_unicode_ci THEN 2 ELSE 0 END), 0)
         + COALESCE(SUM(DISTINCT CASE WHEN LOWER(s.Focus_area) LIKE CONCAT('%', fh.focus_hint, '%') COLLATE utf8mb4_unicode_ci THEN 2 ELSE 0 END), 0)) AS score
    FROM Sponsor s
    LEFT JOIN Sponsor_Interest si ON s.Sponsor_ID = si.Sponsor_ID
    LEFT JOIN temp_sponsor_stems ts ON (LOWER(si.interest) LIKE CONCAT('%', ts.stem, '%') COLLATE utf8mb4_unicode_ci
                                         OR LOWER(s.Focus_area) LIKE CONCAT('%', ts.stem, '%') COLLATE utf8mb4_unicode_ci)
    LEFT JOIN temp_focus_hints fh ON (LOWER(si.interest) LIKE CONCAT('%', fh.focus_hint, '%') COLLATE utf8mb4_unicode_ci
                                      OR LOWER(s.Focus_area) LIKE CONCAT('%', fh.focus_hint, '%') COLLATE utf8mb4_unicode_ci)
    GROUP BY s.Sponsor_ID, s.Name, s.Focus_area
    HAVING score > 0
    ORDER BY score DESC
    LIMIT 10;
    
    DROP TEMPORARY TABLE IF EXISTS temp_sponsor_stems;
    DROP TEMPORARY TABLE IF EXISTS temp_focus_hints;
END $$
DELIMITER ;

-- Example: recommend vendors by matching the event type to vendor service type
DELIMITER $$
-- Procedure: recommend_vendors_for_event (LIKE-based multi-word stem matching + semantic mapping)
DROP PROCEDURE IF EXISTS recommend_vendors_for_event$$
CREATE PROCEDURE recommend_vendors_for_event(IN p_event_type TEXT)
BEGIN
    DECLARE input_text TEXT;
    DECLARE word VARCHAR(255);
    DECLARE stem VARCHAR(255);
    DECLARE remaining TEXT;
    DECLARE word_count INT DEFAULT 0;
    
    SET input_text = LOWER(TRIM(p_event_type));
    SET remaining = input_text;
    
    -- Create a temporary table to hold stems from all words
    DROP TEMPORARY TABLE IF EXISTS temp_stems;
    CREATE TEMPORARY TABLE temp_stems (stem VARCHAR(255));
    
    -- Create a temporary table for semantic service mappings
    DROP TEMPORARY TABLE IF EXISTS temp_service_hints;
    CREATE TEMPORARY TABLE temp_service_hints (service_hint VARCHAR(255));
    
    -- Extract stems from each word (up to 10 words to avoid infinite loops)
    WHILE LENGTH(remaining) > 0 AND word_count < 10 DO
        SET word_count = word_count + 1;
        
        -- Extract next word
        IF LOCATE(' ', remaining) > 0 THEN
            SET word = SUBSTRING_INDEX(remaining, ' ', 1);
            SET remaining = TRIM(SUBSTRING(remaining, LENGTH(word) + 2));
        ELSE
            SET word = remaining;
            SET remaining = '';
        END IF;
        
        -- Create stem (first 6 chars) and insert
        IF LENGTH(word) >= 3 THEN
            SET stem = LEFT(word, 6);
            INSERT INTO temp_stems (stem) VALUES (stem);
            
            -- Semantic mappings: add service type hints based on keywords
            IF word IN ('workshop', 'seminar', 'training', 'conference', 'presentation') THEN
                INSERT INTO temp_service_hints (service_hint) VALUES ('audio'), ('visual');
            END IF;
            IF word IN ('camp', 'checkup', 'health', 'medical', 'clinic', 'hospital') THEN
                INSERT INTO temp_service_hints (service_hint) VALUES ('medical'), ('catering');
            END IF;
            IF word IN ('cleanup', 'drive', 'plantation', 'beach', 'park') THEN
                INSERT INTO temp_service_hints (service_hint) VALUES ('transport'), ('security');
            END IF;
            IF word IN ('celebration', 'party', 'festival', 'ceremony', 'wedding') THEN
                INSERT INTO temp_service_hints (service_hint) VALUES ('decoration'), ('catering'), ('photogr');
            END IF;
            IF word IN ('food', 'meal', 'lunch', 'dinner', 'breakfast', 'refreshment') THEN
                INSERT INTO temp_service_hints (service_hint) VALUES ('catering');
            END IF;
            IF word IN ('photo', 'picture', 'video', 'film', 'camera') THEN
                INSERT INTO temp_service_hints (service_hint) VALUES ('photogr');
            END IF;
            IF word IN ('education', 'educational', 'school', 'student', 'teacher', 'learning') THEN
                INSERT INTO temp_service_hints (service_hint) VALUES ('audio'), ('visual');
            END IF;
        END IF;
    END WHILE;
    
    -- Return vendors with scores based on matches (direct stem matches + semantic hints)
    SELECT
        v.Vendor_ID,
        v.Name,
        v.Service_type,
        -- Score: 4 points for direct service_type match via stem, 2 points for name match, 3 points for semantic hint match
        (COALESCE(SUM(CASE WHEN LOWER(v.Service_type) LIKE CONCAT('%', ts.stem, '%') COLLATE utf8mb4_unicode_ci THEN 4 ELSE 0 END), 0)
         + COALESCE(SUM(CASE WHEN LOWER(v.Name) LIKE CONCAT('%', ts.stem, '%') COLLATE utf8mb4_unicode_ci THEN 2 ELSE 0 END), 0)
         + COALESCE(SUM(CASE WHEN LOWER(v.Service_type) LIKE CONCAT('%', sh.service_hint, '%') COLLATE utf8mb4_unicode_ci THEN 3 ELSE 0 END), 0)) AS score
    FROM Vendor v
    LEFT JOIN temp_stems ts ON (LOWER(v.Service_type) LIKE CONCAT('%', ts.stem, '%') COLLATE utf8mb4_unicode_ci
                                 OR LOWER(v.Name) LIKE CONCAT('%', ts.stem, '%') COLLATE utf8mb4_unicode_ci)
    LEFT JOIN temp_service_hints sh ON LOWER(v.Service_type) LIKE CONCAT('%', sh.service_hint, '%') COLLATE utf8mb4_unicode_ci
    GROUP BY v.Vendor_ID, v.Name, v.Service_type
    HAVING score > 0
    ORDER BY score DESC, v.Name
    LIMIT 10;
    
    DROP TEMPORARY TABLE IF EXISTS temp_stems;
    DROP TEMPORARY TABLE IF EXISTS temp_service_hints;
END $$
DELIMITER ;

-- Notes:
-- 1) The above CREATE PROCEDURE statements require the relevant FULLTEXT indexes to exist.
-- 2) If you re-run this file and an index already exists, the ALTER TABLE will error; in that case
--    drop the existing index first or run only the CREATE PROCEDURE parts.
-- 3) To call from the API you can either CALL the procedures or run an equivalent SELECT with
--    MATCH...AGAINST using a parameter.
