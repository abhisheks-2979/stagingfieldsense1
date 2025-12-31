import { serve } from "https://deno.land/std@0.168.0/http/server.ts";

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

// Tally XML request to get company info
const TALLY_COMPANY_REQUEST = `<?xml version="1.0" encoding="UTF-8"?>
<ENVELOPE>
  <HEADER>
    <VERSION>1</VERSION>
    <TALLYREQUEST>Export</TALLYREQUEST>
    <TYPE>Collection</TYPE>
    <ID>List of Companies</ID>
  </HEADER>
  <BODY>
    <DESC>
      <STATICVARIABLES>
        <SVEXPORTFORMAT>$$SysName:XML</SVEXPORTFORMAT>
      </STATICVARIABLES>
      <TDL>
        <TDLMESSAGE>
          <COLLECTION NAME="List of Companies" ISMODIFY="No" ISFIXED="No" ISINITIALIZE="No" ISOPTION="No" ISINTERNAL="No">
            <TYPE>Company</TYPE>
            <NATIVEMETHOD>Name</NATIVEMETHOD>
            <NATIVEMETHOD>Address</NATIVEMETHOD>
            <NATIVEMETHOD>GSTIN</NATIVEMETHOD>
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

    // Parse the XML to extract company data
    const companies = parseCompanyXml(xmlData);
    
    if (companies.length === 0) {
      console.log("No companies found in XML response");
      return new Response(JSON.stringify({ 
        success: false, 
        error: "No company data found in Tally response",
        companies: [] 
      }), {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      });
    }

    console.log(`Found ${companies.length} companies`);

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

// Simple XML parser to extract company data
function parseCompanyXml(xml: string): Array<{ name: string; address: string; gstin: string }> {
  const companies: Array<{ name: string; address: string; gstin: string }> = [];
  
  // Match COMPANY blocks
  const companyRegex = /<COMPANY[^>]*>([\s\S]*?)<\/COMPANY>/gi;
  let match;
  
  while ((match = companyRegex.exec(xml)) !== null) {
    const companyBlock = match[1];
    
    // Extract fields
    const nameMatch = /<NAME[^>]*>(.*?)<\/NAME>/i.exec(companyBlock);
    const addressMatch = /<ADDRESS[^>]*>(.*?)<\/ADDRESS>/i.exec(companyBlock);
    const gstinMatch = /<GSTIN[^>]*>(.*?)<\/GSTIN>/i.exec(companyBlock) || 
                       /<PARTYGSTIN[^>]*>(.*?)<\/PARTYGSTIN>/i.exec(companyBlock);
    
    if (nameMatch) {
      companies.push({
        name: nameMatch[1].trim(),
        address: addressMatch ? addressMatch[1].trim().replace(/&#10;/g, ', ') : '',
        gstin: gstinMatch ? gstinMatch[1].trim() : ''
      });
    }
  }
  
  // If no COMPANY blocks found, try alternate patterns
  if (companies.length === 0) {
    const nameMatch = /<NAME[^>]*>(.*?)<\/NAME>/gi.exec(xml);
    const addressMatch = /<ADDRESS[^>]*>([\s\S]*?)<\/ADDRESS>/gi.exec(xml);
    const gstinMatch = /<GSTIN[^>]*>(.*?)<\/GSTIN>/gi.exec(xml);
    
    if (nameMatch) {
      companies.push({
        name: nameMatch[1].trim(),
        address: addressMatch ? addressMatch[1].trim().replace(/&#10;/g, ', ').replace(/<[^>]+>/g, ', ') : '',
        gstin: gstinMatch ? gstinMatch[1].trim() : ''
      });
    }
  }
  
  return companies;
}
