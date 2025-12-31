/**
 * Tally Prime Local Proxy Server
 * 
 * This proxy bridges your React app with the local Tally Prime server.
 * It handles CORS and converts Tally's XML responses to JSON.
 * 
 * Usage:
 *   1. Ensure Tally Prime is running on localhost:9000
 *   2. Run: node tally-proxy.js
 *   3. The proxy will be available at http://localhost:3001
 */

const http = require('http');

const TALLY_HOST = 'localhost';
const TALLY_PORT = 9000;
const PROXY_PORT = 3001;

// XML request to fetch company data from Tally
const COMPANY_REQUEST_XML = `<?xml version="1.0" encoding="UTF-8"?>
<ENVELOPE>
  <HEADER>
    <VERSION>1</VERSION>
    <TALLYREQUEST>Export</TALLYREQUEST>
    <TYPE>Data</TYPE>
    <ID>MyReport</ID>
  </HEADER>
  <BODY>
    <DESC>
      <STATICVARIABLES>
        <SVEXPORTFORMAT>$$SysName:XML</SVEXPORTFORMAT>
      </STATICVARIABLES>
      <TDL>
        <TDLMESSAGE>
          <REPORT NAME="MyReport">
            <FORMS>MyForm</FORMS>
          </REPORT>
          <FORM NAME="MyForm">
            <PARTS>MyPart</PARTS>
          </FORM>
          <PART NAME="MyPart">
            <LINES>MyLine</LINES>
            <REPEAT>MyLine : MyCollection</REPEAT>
            <SCROLLED>Vertical</SCROLLED>
          </PART>
          <LINE NAME="MyLine">
            <FIELDS>FldName,FldAddress,FldGSTIN</FIELDS>
          </LINE>
          <FIELD NAME="FldName">
            <SET>$Name</SET>
            <XMLTAG>COMPANYNAME</XMLTAG>
          </FIELD>
          <FIELD NAME="FldAddress">
            <SET>$Address</SET>
            <XMLTAG>ADDRESS</XMLTAG>
          </FIELD>
          <FIELD NAME="FldGSTIN">
            <SET>$GSTIN</SET>
            <XMLTAG>GSTIN</XMLTAG>
          </FIELD>
          <COLLECTION NAME="MyCollection">
            <TYPE>Company</TYPE>
          </COLLECTION>
        </TDLMESSAGE>
      </TDL>
    </DESC>
  </BODY>
</ENVELOPE>`;

// Simple XML parser for Tally response
function parseCompanyXML(xml) {
  const companies = [];
  
  // Match all MYLINE blocks
  const lineRegex = /<MYLINE>([\s\S]*?)<\/MYLINE>/gi;
  let lineMatch;
  
  while ((lineMatch = lineRegex.exec(xml)) !== null) {
    const lineContent = lineMatch[1];
    
    const nameMatch = /<COMPANYNAME>([\s\S]*?)<\/COMPANYNAME>/i.exec(lineContent);
    const addressMatch = /<ADDRESS>([\s\S]*?)<\/ADDRESS>/i.exec(lineContent);
    const gstinMatch = /<GSTIN>([\s\S]*?)<\/GSTIN>/i.exec(lineContent);
    
    companies.push({
      name: nameMatch ? nameMatch[1].trim() : '',
      address: addressMatch ? addressMatch[1].trim().replace(/&#13;&#10;/g, ', ').replace(/\s+/g, ' ') : '',
      gstin: gstinMatch ? gstinMatch[1].trim() : ''
    });
  }
  
  // If no MYLINE found, try alternative parsing for single company
  if (companies.length === 0) {
    const nameMatch = /<COMPANYNAME>([\s\S]*?)<\/COMPANYNAME>/i.exec(xml);
    const addressMatch = /<ADDRESS>([\s\S]*?)<\/ADDRESS>/i.exec(xml);
    const gstinMatch = /<GSTIN>([\s\S]*?)<\/GSTIN>/i.exec(xml);
    
    if (nameMatch || addressMatch || gstinMatch) {
      companies.push({
        name: nameMatch ? nameMatch[1].trim() : '',
        address: addressMatch ? addressMatch[1].trim().replace(/&#13;&#10;/g, ', ').replace(/\s+/g, ' ') : '',
        gstin: gstinMatch ? gstinMatch[1].trim() : ''
      });
    }
  }
  
  return companies;
}

// Send request to Tally Prime
function fetchFromTally() {
  return new Promise((resolve, reject) => {
    const options = {
      hostname: TALLY_HOST,
      port: TALLY_PORT,
      path: '/',
      method: 'POST',
      headers: {
        'Content-Type': 'application/xml',
        'Content-Length': Buffer.byteLength(COMPANY_REQUEST_XML)
      }
    };

    const req = http.request(options, (res) => {
      let data = '';
      res.on('data', (chunk) => { data += chunk; });
      res.on('end', () => {
        try {
          const companies = parseCompanyXML(data);
          resolve({ success: true, companies, raw: data });
        } catch (error) {
          reject(new Error('Failed to parse Tally response: ' + error.message));
        }
      });
    });

    req.on('error', (error) => {
      reject(new Error('Failed to connect to Tally: ' + error.message));
    });

    req.setTimeout(10000, () => {
      req.destroy();
      reject(new Error('Connection to Tally timed out'));
    });

    req.write(COMPANY_REQUEST_XML);
    req.end();
  });
}

// Create proxy server
const server = http.createServer(async (req, res) => {
  // CORS headers
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');
  
  if (req.method === 'OPTIONS') {
    res.writeHead(204);
    res.end();
    return;
  }

  if (req.url === '/api/tally/company' && req.method === 'GET') {
    try {
      const result = await fetchFromTally();
      res.writeHead(200, { 'Content-Type': 'application/json' });
      res.end(JSON.stringify(result));
    } catch (error) {
      res.writeHead(500, { 'Content-Type': 'application/json' });
      res.end(JSON.stringify({ 
        success: false, 
        error: error.message,
        companies: [] 
      }));
    }
  } else if (req.url === '/health') {
    res.writeHead(200, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({ status: 'ok', tallyHost: `${TALLY_HOST}:${TALLY_PORT}` }));
  } else {
    res.writeHead(404, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({ error: 'Not found' }));
  }
});

server.listen(PROXY_PORT, () => {
  console.log(`\n🚀 Tally Proxy Server running at http://localhost:${PROXY_PORT}`);
  console.log(`📡 Proxying requests to Tally Prime at http://${TALLY_HOST}:${TALLY_PORT}`);
  console.log(`\nEndpoints:`);
  console.log(`  GET /api/tally/company - Fetch company data`);
  console.log(`  GET /health            - Health check\n`);
});
