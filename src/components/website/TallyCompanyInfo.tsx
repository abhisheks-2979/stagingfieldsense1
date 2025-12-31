import { useState, useEffect } from "react";
import { Card } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Building2, MapPin, FileText, Wifi, WifiOff, RefreshCw, Phone, Mail } from "lucide-react";
import { Button } from "@/components/ui/button";
import { supabase } from "@/integrations/supabase/client";

interface CompanyData {
  name: string;
  address: string;
  phone: string;
  email: string;
  gstin: string;
  pan: string;
  state: string;
  pincode: string;
}

const DEMO_COMPANIES: CompanyData[] = [
  {
    name: "Demo Company Pvt Ltd",
    address: "123 Business Park, Mumbai, Maharashtra 400001",
    phone: "+91 98765 43210",
    email: "info@democompany.com",
    gstin: "27AABCD1234E1Z5",
    pan: "AABCD1234E",
    state: "Maharashtra",
    pincode: "400001"
  }
];

export const TallyCompanyInfo = () => {
  const [companies, setCompanies] = useState<CompanyData[]>([]);
  const [isConnected, setIsConnected] = useState(false);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const fetchCompanyData = async () => {
    setIsLoading(true);
    setError(null);
    
    try {
      // Call the Supabase edge function that proxies to Tally via ngrok
      const { data, error: fnError } = await supabase.functions.invoke('tally-proxy');
      
      if (fnError) {
        throw new Error(fnError.message);
      }
      
      if (data.success && data.companies && data.companies.length > 0) {
        setCompanies(data.companies);
        setIsConnected(true);
      } else {
        throw new Error(data.error || "No company data found");
      }
    } catch (err) {
      console.log("Tally connection failed, using demo data:", err);
      setCompanies(DEMO_COMPANIES);
      setIsConnected(false);
      setError(err instanceof Error ? err.message : "Connection failed");
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => {
    fetchCompanyData();
  }, []);

  if (isLoading) {
    return (
      <section className="pt-28 pb-4 px-4">
        <div className="container mx-auto max-w-4xl">
          <Card className="p-6 bg-muted/30 border-border animate-pulse">
            <div className="flex items-center gap-4">
              <div className="w-14 h-14 rounded-lg bg-muted"></div>
              <div className="flex-1 space-y-2">
                <div className="h-5 bg-muted rounded w-1/3"></div>
                <div className="h-4 bg-muted rounded w-2/3"></div>
              </div>
            </div>
          </Card>
        </div>
      </section>
    );
  }

  if (companies.length === 0) return null;

  return (
    <section className="pt-28 pb-4 px-4">
      <div className="container mx-auto max-w-4xl space-y-3">
        {/* Header with connection status and refresh */}
        <div className="flex items-center justify-between">
          <div className="flex items-center gap-2">
            <Badge 
              variant={isConnected ? "default" : "secondary"} 
              className="text-xs"
            >
              {isConnected ? (
                <>
                  <Wifi className="w-3 h-3 mr-1" />
                  Tally Connected ({companies.length} {companies.length === 1 ? 'company' : 'companies'})
                </>
              ) : (
                <>
                  <WifiOff className="w-3 h-3 mr-1" />
                  Demo Mode
                </>
              )}
            </Badge>
          </div>
          <Button
            variant="ghost"
            size="sm"
            onClick={fetchCompanyData}
            className="h-8"
            title="Refresh company data"
          >
            <RefreshCw className={`w-4 h-4 mr-1.5 ${isLoading ? "animate-spin" : ""}`} />
            Refresh
          </Button>
        </div>

        {/* Company Cards */}
        {companies.map((company, index) => (
          <Card 
            key={index} 
            className="p-5 bg-gradient-to-r from-primary/5 to-primary/10 border-primary/20"
          >
            <div className="flex flex-col sm:flex-row items-start gap-4">
              {/* Company Icon */}
              <div className="w-12 h-12 rounded-lg bg-primary/10 flex items-center justify-center flex-shrink-0">
                <Building2 className="w-6 h-6 text-primary" />
              </div>
              
              {/* Company Details */}
              <div className="flex-1 min-w-0 space-y-2">
                <h3 className="text-base font-bold text-foreground">
                  {company.name}
                </h3>
                
                <div className="grid grid-cols-1 sm:grid-cols-2 gap-2 text-sm text-muted-foreground">
                  {/* Address */}
                  {company.address && (
                    <div className="flex items-start gap-1.5 sm:col-span-2">
                      <MapPin className="w-3.5 h-3.5 text-primary flex-shrink-0 mt-0.5" />
                      <span>{company.address}</span>
                    </div>
                  )}
                  
                  {/* Phone */}
                  {company.phone && (
                    <div className="flex items-center gap-1.5">
                      <Phone className="w-3.5 h-3.5 text-primary flex-shrink-0" />
                      <span>{company.phone}</span>
                    </div>
                  )}
                  
                  {/* Email */}
                  {company.email && (
                    <div className="flex items-center gap-1.5">
                      <Mail className="w-3.5 h-3.5 text-primary flex-shrink-0" />
                      <span className="truncate">{company.email}</span>
                    </div>
                  )}
                  
                  {/* GSTIN */}
                  {company.gstin && (
                    <div className="flex items-center gap-1.5">
                      <FileText className="w-3.5 h-3.5 text-primary flex-shrink-0" />
                      <span className="font-mono text-xs">GSTIN: {company.gstin}</span>
                    </div>
                  )}
                  
                  {/* PAN */}
                  {company.pan && (
                    <div className="flex items-center gap-1.5">
                      <FileText className="w-3.5 h-3.5 text-primary flex-shrink-0" />
                      <span className="font-mono text-xs">PAN: {company.pan}</span>
                    </div>
                  )}
                </div>
              </div>
            </div>
          </Card>
        ))}
        
        {!isConnected && error && (
          <p className="text-xs text-muted-foreground text-center">
            Ensure Tally Prime is running and ngrok is active to connect
          </p>
        )}
      </div>
    </section>
  );
};
