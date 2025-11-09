-- Update events to assign sponsors based on event type and sponsor focus area
USE ngo_management;

-- Update Educational Workshop events with Education-focused sponsors
UPDATE Event e
SET e.Sponsor_Person_ID = (
    SELECT sp.Sponsor_Person_ID 
    FROM Sponsor_Person sp
    INNER JOIN Sponsor s ON sp.Sponsor_ID = s.Sponsor_ID
    WHERE s.Focus_area = 'Education'
    LIMIT 1
)
WHERE e.Event_Type LIKE '%Education%' 
  OR e.Event_Type LIKE '%Workshop%'
  OR e.Event_Type LIKE '%Training%'
  AND e.Sponsor_Person_ID IS NULL;

-- Update Environment-related events with Environment-focused sponsors
UPDATE Event e
SET e.Sponsor_Person_ID = (
    SELECT sp.Sponsor_Person_ID 
    FROM Sponsor_Person sp
    INNER JOIN Sponsor s ON sp.Sponsor_ID = s.Sponsor_ID
    WHERE s.Focus_area = 'Environment'
    LIMIT 1
)
WHERE (e.Event_Type LIKE '%Tree%' 
  OR e.Event_Type LIKE '%Environment%'
  OR e.Event_Type LIKE '%Plantation%')
  AND e.Sponsor_Person_ID IS NULL;

-- Update Healthcare events with Healthcare-focused sponsors
UPDATE Event e
SET e.Sponsor_Person_ID = (
    SELECT sp.Sponsor_Person_ID 
    FROM Sponsor_Person sp
    INNER JOIN Sponsor s ON sp.Sponsor_ID = s.Sponsor_ID
    WHERE s.Focus_area = 'Healthcare'
    LIMIT 1
)
WHERE (e.Event_Type LIKE '%Health%' 
  OR e.Event_Type LIKE '%Medical%'
  OR e.Event_Type LIKE '%Clinic%')
  AND e.Sponsor_Person_ID IS NULL;

-- Update Child Welfare events with Child Welfare-focused sponsors
UPDATE Event e
SET e.Sponsor_Person_ID = (
    SELECT sp.Sponsor_Person_ID 
    FROM Sponsor_Person sp
    INNER JOIN Sponsor s ON sp.Sponsor_ID = s.Sponsor_ID
    WHERE s.Focus_area = 'Child Welfare'
    LIMIT 1
)
WHERE (e.Event_Type LIKE '%Child%' 
  OR e.Event_Type LIKE '%Youth%'
  OR e.Event_Type LIKE '%School%')
  AND e.Sponsor_Person_ID IS NULL;

-- Update Women Empowerment events with Women Empowerment-focused sponsors
UPDATE Event e
SET e.Sponsor_Person_ID = (
    SELECT sp.Sponsor_Person_ID 
    FROM Sponsor_Person sp
    INNER JOIN Sponsor s ON sp.Sponsor_ID = s.Sponsor_ID
    WHERE s.Focus_area = 'Women Empowerment'
    LIMIT 1
)
WHERE (e.Event_Type LIKE '%Women%' 
  OR e.Event_Type LIKE '%Girls%'
  OR e.Event_Type LIKE '%Female%')
  AND e.Sponsor_Person_ID IS NULL;

-- Verify the updates
SELECT 
    e.Event_ID,
    e.Event_Type,
    e.Sponsor_Person_ID,
    s.Name AS sponsor_name,
    s.Focus_area
FROM Event e
LEFT JOIN Sponsor_Person sp ON e.Sponsor_Person_ID = sp.Sponsor_Person_ID
LEFT JOIN Sponsor s ON sp.Sponsor_ID = s.Sponsor_ID
ORDER BY e.Event_ID;
