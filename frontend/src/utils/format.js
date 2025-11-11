export function currency(v) {
  if (v === null || v === undefined) return '₹0'
  const n = Number(v)
  if (isNaN(n)) return v
  return new Intl.NumberFormat('en-IN', { style: 'currency', currency: 'INR', maximumFractionDigits: 2 }).format(n)
}
