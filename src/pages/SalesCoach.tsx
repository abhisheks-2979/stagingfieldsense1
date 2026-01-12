import { Layout } from "@/components/Layout";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Bot, MessageSquare, Target, TrendingUp } from "lucide-react";

const SalesCoach = () => {
  return (
    <Layout>
      <div className="p-4 space-y-4">
        <div className="flex items-center gap-3">
          <div className="p-2 rounded-lg bg-primary/10">
            <Bot className="h-6 w-6 text-primary" />
          </div>
          <div>
            <h1 className="text-xl font-bold">Sales Coach</h1>
            <p className="text-sm text-muted-foreground">Your AI-powered sales assistant</p>
          </div>
        </div>

        <div className="grid gap-4">
          <Card>
            <CardHeader className="pb-2">
              <CardTitle className="text-base flex items-center gap-2">
                <MessageSquare className="h-4 w-4 text-blue-500" />
                Daily Tips
              </CardTitle>
            </CardHeader>
            <CardContent>
              <p className="text-sm text-muted-foreground">
                Get personalized sales tips and recommendations based on your performance.
              </p>
            </CardContent>
          </Card>

          <Card>
            <CardHeader className="pb-2">
              <CardTitle className="text-base flex items-center gap-2">
                <Target className="h-4 w-4 text-green-500" />
                Goal Tracking
              </CardTitle>
            </CardHeader>
            <CardContent>
              <p className="text-sm text-muted-foreground">
                Track your daily, weekly, and monthly targets with intelligent insights.
              </p>
            </CardContent>
          </Card>

          <Card>
            <CardHeader className="pb-2">
              <CardTitle className="text-base flex items-center gap-2">
                <TrendingUp className="h-4 w-4 text-purple-500" />
                Performance Insights
              </CardTitle>
            </CardHeader>
            <CardContent>
              <p className="text-sm text-muted-foreground">
                Analyze your sales patterns and get actionable recommendations.
              </p>
            </CardContent>
          </Card>
        </div>

        <Card className="bg-primary/5 border-primary/20">
          <CardContent className="py-6 text-center">
            <Bot className="h-12 w-12 mx-auto text-primary/50 mb-3" />
            <p className="text-sm text-muted-foreground">
              Sales Coach features are being enhanced. Check back soon for AI-powered coaching!
            </p>
          </CardContent>
        </Card>
      </div>
    </Layout>
  );
};

export default SalesCoach;
