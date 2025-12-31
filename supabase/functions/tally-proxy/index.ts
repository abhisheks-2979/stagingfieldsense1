import { serve } from "https://deno.land/std@0.168.0/http/server.ts";

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

// Tally XML request to get company info with all details
const TALLY_COMPANY_REQUEST = `<?xml version="1.0" encoding="UTF-8"?>
<ENVELOPE>
  <HEADER>
    <VERSION>1</VERSION>
    <TALLYREQUEST>Export</TALLYREQUEST>
    <TYPE>Collection</TYPE>
    <ID>CompanyDetails</ID>
  </HEADER>
  <BODY>
    <DESC>
      <STATICVARIABLES>
        <SVEXPORTFORMAT>$$SysName:XML</SVEXPORTFORMAT>
      </STATICVARIABLES>
      <TDL>
        <TDLMESSAGE>
          <COLLECTION NAME="CompanyDetails" ISMODIFY="No" ISFIXED="No" ISINITIALIZE="No" ISOPTION="No" ISINTERNAL="No">
            <TYPE>Company</TYPE>
            <NATIVEMETHOD>Name</NATIVEMETHOD>
            <NATIVEMETHOD>Address</NATIVEMETHOD>
            <NATIVEMETHOD>StateName</NATIVEMETHOD>
            <NATIVEMETHOD>PinCode</NATIVEMETHOD>
            <NATIVEMETHOD>PhoneNumber</NATIVEMETHOD>
            <NATIVEMETHOD>MobileNo</NATIVEMETHOD>
            <NATIVEMETHOD>FaxNumber</NATIVEMETHOD>
            <NATIVEMETHOD>Email</NATIVEMETHOD>
            <NATIVEMETHOD>Website</NATIVEMETHOD>
            <NATIVEMETHOD>GSTIN</NATIVEMETHOD>
            <NATIVEMETHOD>PartyGSTIN</NATIVEMETHOD>
            <NATIVEMETHOD>GSTRegistrationType</NATIVEMETHOD>
            <NATIVEMETHOD>PAN</NATIVEMETHOD>
            <NATIVEMETHOD>CINNumber</NATIVEMETHOD>
            <NATIVEMETHOD>IncomeTaxNumber</NATIVEMETHOD>
          </COLLECTION>
        </TDLMESSAGE>
      </TDL>
    </DESC>
  </BODY>
</ENVELOPE>`;

// Your ngrok URL - this proxies to your local Tally Prime on port 9000
const TALLY_NGROK_URL = "https://postlabial-compressed-sabina.ngrok-free.dev";

serve(async (req) => {
  // Handle CORS preflight requests
  if (req.method === 'OPTIONS') {
    return new Response(null, { headers: corsHeaders });
  }

  try {
    console.log("Fetching company data from Tally via ngrok...");
    
    // Make request to Tally through ngrok
    const response = await fetch(TALLY_NGROK_URL, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/xml',
        'ngrok-skip-browser-warning': 'true'
      },
      body: TALLY_COMPANY_REQUEST,
    });

    if (!response.ok) {
      console.error("Tally response not ok:", response.status, response.statusText);
      throw new Error(`Tally returned ${response.status}: ${response.statusText}`);
    }

    const xmlData = await response.text();
    console.log("Received XML response from Tally, length:", xmlData.length);
    console.log("XML preview:", xmlData.substring(0, 1000));

    // Parse the XML to extract company data
    const companies = parseCompanyXml(xmlData);
    
    if (companies.length === 0) {
      console.log("No companies found in XML response");
      return new Response(JSON.stringify({ 
        success: false, 
        error: "No company data found in Tally response",
        companies: [],
        rawXml: xmlData.substring(0, 2000)
      }), {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      });
    }

    console.log(`Found ${companies.length} companies:`, JSON.stringify(companies));

    return new Response(JSON.stringify({ 
      success: true, 
      companies 
    }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    });

  } catch (error) {
    console.error('Error fetching from Tally:', error);
    return new Response(JSON.stringify({ 
      success: false, 
      error: error.message,
      companies: [] 
    }), {
      status: 500,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    });
  }
});

interface CompanyInfo {
  name: string;
  address: string;
  phone: string;
  email: string;
  gstin: string;
  pan: string;
  state: string;
  pincode: string;
}

// Extract value from XML tag
function extractValue(xml: string, tagName: string): string {
  const patterns = [
    new RegExp(`<${tagName}[^>]*>([^<]*)</${tagName}>`, 'i'),
    new RegExp(`<${tagName}\\.LIST[^>]*>([\\s\\S]*?)</${tagName}\\.LIST>`, 'i'),
  ];
  
  for (const pattern of patterns) {
    const match = pattern.exec(xml);
    if (match && match[1]) {
      // Clean up the value
      return match[1]
        .replace(/&#10;/g, ', ')
        .replace(/&#13;/g, '')
        .replace(/<[^>]+>/g, ' ')
        .replace(/\s+/g, ' ')
        .trim();
    }
  }
  return '';
}

// Simple XML parser to extract company data
function parseCompanyXml(xml: string): CompanyInfo[] {
  const companies: CompanyInfo[] = [];
  
  // Try to match COMPANY blocks
  const companyRegex = /<COMPANY[^>]*>([\s\S]*?)<\/COMPANY>/gi;
  let match;
  
  while ((match = companyRegex.exec(xml)) !== null) {
    const block = match[1];
    const company = extractCompanyFromBlock(block);
    if (company.name) {
      companies.push(company);
    }
  }
  
  // If no COMPANY blocks, try COMPANYDETAILS or root level
  if (companies.length === 0) {
    const detailsRegex = /<COMPANYDETAILS[^>]*>([\s\S]*?)<\/COMPANYDETAILS>/gi;
    while ((match = detailsRegex.exec(xml)) !== null) {
      const block = match[1];
      const company = extractCompanyFromBlock(block);
      if (company.name) {
        companies.push(company);
      }
    }
  }
  
  // Last resort: extract from root
  if (companies.length === 0) {
    const company = extractCompanyFromBlock(xml);
    if (company.name) {
      companies.push(company);
    }
  }
  
  return companies;
}

function extractCompanyFromBlock(block: string): CompanyInfo {
  // Extract address - handle multi-line ADDRESS.LIST
  let address = '';
  const addressListMatch = /<ADDRESS\.LIST[^>]*>([\s\S]*?)<\/ADDRESS\.LIST>/i.exec(block);
  if (addressListMatch) {
    const addressLines: string[] = [];
    const lineRegex = /<ADDRESS[^.][^>]*>([^<]*)<\/ADDRESS>/gi;
    let lineMatch;
    while ((lineMatch = lineRegex.exec(addressListMatch[1])) !== null) {
      if (lineMatch[1].trim()) {
        addressLines.push(lineMatch[1].trim());
      }
    }
    address = addressLines.join(', ');
  }
  
  if (!address) {
    address = extractValue(block, 'ADDRESS');
  }

  // Extract phone - try multiple fields
  let phone = extractValue(block, 'PHONENUMBER') || 
              extractValue(block, 'MOBILENO') || 
              extractValue(block, 'MOBILE') ||
              extractValue(block, 'PHONE');

  // Extract state and pincode
  const state = extractValue(block, 'STATENAME') || extractValue(block, 'STATE');
  const pincode = extractValue(block, 'PINCODE');
  
  // Build full address
  const addressParts = [address, state, pincode].filter(Boolean);
  const fullAddress = addressParts.join(', ');

  return {
    name: extractValue(block, 'NAME'),
    address: fullAddress,
    phone: phone,
    email: extractValue(block, 'EMAIL'),
    gstin: extractValue(block, 'GSTIN') || extractValue(block, 'PARTYGSTIN'),
    pan: extractValue(block, 'PAN') || extractValue(block, 'INCOMETAXNUMBER'),
    state: state,
    pincode: pincode,
  };
}
