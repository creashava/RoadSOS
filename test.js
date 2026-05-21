const lat = 12.9716; 
const lng = 77.5946; 
const radiusMeters = 10000;
const SERVICE_SELECTORS = {
  hospital: ['nwr["amenity"="hospital"]'],
};
const selectors = Object.values(SERVICE_SELECTORS).flat();
const queryStatements = selectors.map(sel => `${sel}(around:${radiusMeters},${lat},${lng});`).join('\n    ');

async function test(querySuffix) {
  const overpassQuery = `[out:json][timeout:25];\n(\n  ${queryStatements}\n);\n${querySuffix}`;
  try {
    const r = await fetch('https://overpass-api.de/api/interpreter', {
      method: 'POST',
      body: `data=${encodeURIComponent(overpassQuery)}`,
      headers: { 'Content-Type': 'application/x-www-form-urlencoded' }
    });
    const j = await r.json();
    console.log(`Query ${querySuffix}: found ${j.elements.length} elements`);
    if (j.elements.length > 0) {
      console.log('Sample tags:', j.elements[0].tags);
    }
  } catch(e) {
    console.error(e);
  }
}

test('out center;');
test('out center tags;');
