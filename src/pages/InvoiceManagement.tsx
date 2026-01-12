import { useNavigate } from "react-router-dom";
import { Button } from "@/components/ui/button";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { ArrowLeft, FileText, ListOrdered } from "lucide-react";
import InvoiceTemplateSelector from "@/components/invoice/InvoiceTemplateSelector";
import AllInvoicesList from "@/components/invoice/AllInvoicesList";
import { Layout } from "@/components/Layout";

export default function InvoiceManagement() {
  const navigate = useNavigate();

  return (
    <Layout>
      <div className="container mx-auto p-6 space-y-6">
        <div className="flex items-center gap-4">
          <Button
            variant="ghost"
            size="icon"
            onClick={() => navigate("/admin-controls")}
          >
            <ArrowLeft className="h-5 w-5" />
          </Button>
          <div>
            <h1 className="text-2xl font-bold">Invoice Management</h1>
            <p className="text-muted-foreground">
              Create and manage GST invoices with templates
            </p>
          </div>
        </div>

        <Tabs defaultValue="template" className="space-y-4">
          <TabsList className="grid w-full max-w-md grid-cols-2">
            <TabsTrigger value="template" className="flex items-center gap-2">
              <FileText className="h-4 w-4" />
              Invoice Template
            </TabsTrigger>
            <TabsTrigger value="invoices" className="flex items-center gap-2">
              <ListOrdered className="h-4 w-4" />
              All Invoices
            </TabsTrigger>
          </TabsList>

          <TabsContent value="template">
            <InvoiceTemplateSelector />
          </TabsContent>

          <TabsContent value="invoices">
            <AllInvoicesList />
          </TabsContent>
        </Tabs>
      </div>
    </Layout>
  );
}
