import { useState, useEffect } from "react";
import { Card } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Building2, MapPin, FileText, Wifi, WifiOff, RefreshCw } from "lucide-react";
import { Button } from "@/components/ui/button";

interface CompanyData {
  name: string;
  address: string;
  gstin: string;
}

const DEMO_COMPANY: CompanyData = {
  name: "Demo Company Pvt Ltd",
  address: "123 Business Park, Mumbai, Maharashtra 400001",
  gstin: "27AABCD1234E1Z5"
};

export const TallyCompanyInfo = () => {
  const [company, setCompany] = useState<CompanyData | null>(null);
  const [isConnected, setIsConnected] = useState(false);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const fetchCompanyData = async () => {
    setIsLoading(true);
    setError(null);
    
    try {
      const response = await fetch("http://localhost:3001/api/tally/company", {
        method: "GET",
        headers: { "Content-Type": "application/json" }
      });
      
      if (!response.ok) {
        throw new Error("Failed to fetch from proxy");
      }
      
      const data = await response.json();
      
      if (data.success && data.companies && data.companies.length > 0) {
        setCompany(data.companies[0]);
        setIsConnected(true);
      } else {
        throw new Error(data.error || "No company data found");
      }
    } catch (err) {
      console.log("Tally proxy not available, using demo data");
      setCompany(DEMO_COMPANY);
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

  if (!company) return null;

  return (
    <section className="pt-28 pb-4 px-4">
      <div className="container mx-auto max-w-4xl">
        <Card className="p-6 bg-gradient-to-r from-primary/5 to-primary/10 border-primary/20">
          <div className="flex flex-col sm:flex-row items-start sm:items-center gap-4">
            {/* Company Icon */}
            <div className="w-14 h-14 rounded-lg bg-primary/10 flex items-center justify-center flex-shrink-0">
              <Building2 className="w-7 h-7 text-primary" />
            </div>
            
            {/* Company Details */}
            <div className="flex-1 min-w-0">
              <div className="flex items-center gap-2 mb-1">
                <h3 className="text-lg font-bold text-foreground truncate">
                  {company.name}
                </h3>
                <Badge 
                  variant={isConnected ? "default" : "secondary"} 
                  className="text-xs flex-shrink-0"
                >
                  {isConnected ? (
                    <>
                      <Wifi className="w-3 h-3 mr-1" />
                      Tally Connected
                    </>
                  ) : (
                    <>
                      <WifiOff className="w-3 h-3 mr-1" />
                      Demo Mode
                    </>
                  )}
                </Badge>
              </div>
              
              <div className="flex flex-col sm:flex-row sm:items-center gap-2 sm:gap-4 text-sm text-muted-foreground">
                <span className="flex items-center gap-1.5">
                  <MapPin className="w-4 h-4 text-primary flex-shrink-0" />
                  <span className="truncate">{company.address}</span>
                </span>
                {company.gstin && (
                  <span className="flex items-center gap-1.5">
                    <FileText className="w-4 h-4 text-primary flex-shrink-0" />
                    <span className="font-mono">{company.gstin}</span>
                  </span>
                )}
              </div>
            </div>
            
            {/* Refresh Button */}
            <Button
              variant="ghost"
              size="icon"
              onClick={fetchCompanyData}
              className="flex-shrink-0"
              title="Refresh company data"
            >
              <RefreshCw className={`w-4 h-4 ${isLoading ? "animate-spin" : ""}`} />
            </Button>
          </div>
          
          {!isConnected && error && (
            <p className="text-xs text-muted-foreground mt-3 pl-[72px]">
              Run <code className="bg-muted px-1.5 py-0.5 rounded text-primary">node tally-proxy.js</code> to connect to Tally Prime
            </p>
          )}
        </Card>
      </div>
    </section>
  );
};
