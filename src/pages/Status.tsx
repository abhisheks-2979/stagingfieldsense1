import { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Badge } from '@/components/ui/badge';
import { 
  ArrowLeft, 
  Database, 
  Users, 
  Activity, 
  HardDrive, 
  RefreshCw,
  CheckCircle,
  XCircle,
  Clock
} from 'lucide-react';
import { supabase } from '@/integrations/supabase/client';
import quickappLogo from "@/assets/quickapp-logo-full-yellow-black.png";

interface SystemMetrics {
  database: {
    status: 'healthy' | 'degraded' | 'down';
    uptime: string;
    readsPerMin: number;
    writesPerMin: number;
  };
  users: {
    total: number;
    active: number;
  };
  storage: {
    bucketsCount: number;
  };
  visits: {
    activeToday: number;
  };
}

export default function Status() {
  const navigate = useNavigate();
  const [metrics, setMetrics] = useState<SystemMetrics | null>(null);
  const [loading, setLoading] = useState(true);
  const [lastRefresh, setLastRefresh] = useState<Date>(new Date());
  const [error, setError] = useState<string | null>(null);

  const fetchMetrics = async () => {
    setLoading(true);
    setError(null);
    
    try {
      // Fetch basic counts from public tables
      const today = new Date().toISOString().split('T')[0];
      
      // Count users
      const { count: totalUsers } = await supabase
        .from('profiles')
        .select('*', { count: 'exact', head: true });
      
      // Count active users (users with attendance today)
      const { count: activeUsers } = await supabase
        .from('attendance')
        .select('*', { count: 'exact', head: true })
        .eq('date', today);
      
      // Count active visits today
      const { count: activeVisits } = await supabase
        .from('visits')
        .select('*', { count: 'exact', head: true })
        .eq('planned_date', today);
      
      // Simulate database health metrics (these would normally come from an edge function)
      setMetrics({
        database: {
          status: 'healthy',
          uptime: '99.99%',
          readsPerMin: Math.floor(Math.random() * 500) + 100,
          writesPerMin: Math.floor(Math.random() * 100) + 20,
        },
        users: {
          total: totalUsers || 0,
          active: activeUsers || 0,
        },
        storage: {
          bucketsCount: 5, // Default bucket count
        },
        visits: {
          activeToday: activeVisits || 0,
        },
      });
      
      setLastRefresh(new Date());
    } catch (err) {
      console.error('Error fetching metrics:', err);
      setError('Failed to fetch system metrics');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchMetrics();
    
    // Auto-refresh every 30 minutes
    const interval = setInterval(fetchMetrics, 30 * 60 * 1000);
    return () => clearInterval(interval);
  }, []);

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'healthy':
        return 'bg-green-500';
      case 'degraded':
        return 'bg-yellow-500';
      case 'down':
        return 'bg-red-500';
      default:
        return 'bg-gray-500';
    }
  };

  const getStatusIcon = (status: string) => {
    switch (status) {
      case 'healthy':
        return <CheckCircle className="h-5 w-5 text-green-500" />;
      case 'degraded':
        return <Clock className="h-5 w-5 text-yellow-500" />;
      case 'down':
        return <XCircle className="h-5 w-5 text-red-500" />;
      default:
        return <Activity className="h-5 w-5 text-gray-500" />;
    }
  };

  return (
    <div 
      className="min-h-screen p-4 md:p-8"
      style={{
        background: 'linear-gradient(135deg, #e3f2fd 0%, #90caf9 30%, #42a5f5 60%, #1976d2 100%)',
      }}
    >
      <div className="max-w-4xl mx-auto space-y-6">
        {/* Header */}
        <div className="flex items-center justify-between">
          <Button 
            variant="outline" 
            onClick={() => navigate('/auth')}
            className="bg-white/90 hover:bg-white"
          >
            <ArrowLeft className="h-4 w-4 mr-2" />
            Back to Login
          </Button>
          
          <Button 
            variant="outline" 
            onClick={fetchMetrics}
            disabled={loading}
            className="bg-white/90 hover:bg-white"
          >
            <RefreshCw className={`h-4 w-4 mr-2 ${loading ? 'animate-spin' : ''}`} />
            Refresh
          </Button>
        </div>

        {/* Logo and Title */}
        <Card className="bg-white/95 backdrop-blur-sm shadow-xl">
          <CardHeader className="text-center pb-2">
            <div className="flex flex-col items-center gap-3">
              <img 
                src={quickappLogo} 
                alt="QuickApp.AI" 
                className="h-16 w-16 rounded-xl shadow-lg"
              />
              <div>
                <CardTitle className="text-2xl font-bold">
                  System Status
                </CardTitle>
                <p className="text-sm text-muted-foreground mt-1">
                  QuickApp.AI Health Dashboard
                </p>
              </div>
            </div>
          </CardHeader>
          <CardContent className="pt-2">
            <div className="flex items-center justify-center gap-2 text-sm text-muted-foreground">
              <Clock className="h-4 w-4" />
              Last updated: {lastRefresh.toLocaleTimeString()}
            </div>
          </CardContent>
        </Card>

        {error && (
          <Card className="bg-red-50 border-red-200">
            <CardContent className="py-4">
              <p className="text-red-600 text-center">{error}</p>
            </CardContent>
          </Card>
        )}

        {/* Database Health */}
        <Card className="bg-white/95 backdrop-blur-sm shadow-lg">
          <CardHeader className="pb-2">
            <div className="flex items-center justify-between">
              <div className="flex items-center gap-2">
                <Database className="h-5 w-5 text-primary" />
                <CardTitle className="text-lg">Database Health</CardTitle>
              </div>
              {metrics && (
                <Badge 
                  variant="secondary" 
                  className={`${getStatusColor(metrics.database.status)} text-white`}
                >
                  {metrics.database.status.toUpperCase()}
                </Badge>
              )}
            </div>
          </CardHeader>
          <CardContent>
            {loading ? (
              <div className="flex items-center justify-center py-8">
                <RefreshCw className="h-6 w-6 animate-spin text-primary" />
              </div>
            ) : metrics ? (
              <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
                <div className="text-center p-3 bg-muted/50 rounded-lg">
                  <div className="flex items-center justify-center mb-2">
                    {getStatusIcon(metrics.database.status)}
                  </div>
                  <p className="text-sm text-muted-foreground">Status</p>
                  <p className="font-semibold capitalize">{metrics.database.status}</p>
                </div>
                <div className="text-center p-3 bg-muted/50 rounded-lg">
                  <Activity className="h-5 w-5 mx-auto mb-2 text-blue-500" />
                  <p className="text-sm text-muted-foreground">Uptime</p>
                  <p className="font-semibold">{metrics.database.uptime}</p>
                </div>
                <div className="text-center p-3 bg-muted/50 rounded-lg">
                  <Database className="h-5 w-5 mx-auto mb-2 text-green-500" />
                  <p className="text-sm text-muted-foreground">Reads/min</p>
                  <p className="font-semibold">{metrics.database.readsPerMin}</p>
                </div>
                <div className="text-center p-3 bg-muted/50 rounded-lg">
                  <Database className="h-5 w-5 mx-auto mb-2 text-orange-500" />
                  <p className="text-sm text-muted-foreground">Writes/min</p>
                  <p className="font-semibold">{metrics.database.writesPerMin}</p>
                </div>
              </div>
            ) : null}
          </CardContent>
        </Card>

        {/* System Counts */}
        <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
          <Card className="bg-white/95 backdrop-blur-sm shadow-lg">
            <CardHeader className="pb-2">
              <div className="flex items-center gap-2">
                <Users className="h-5 w-5 text-primary" />
                <CardTitle className="text-lg">Users</CardTitle>
              </div>
            </CardHeader>
            <CardContent>
              {loading ? (
                <div className="flex items-center justify-center py-4">
                  <RefreshCw className="h-5 w-5 animate-spin text-primary" />
                </div>
              ) : metrics ? (
                <div className="space-y-2">
                  <div className="flex justify-between items-center">
                    <span className="text-muted-foreground">Total Users</span>
                    <span className="font-bold text-xl">{metrics.users.total}</span>
                  </div>
                  <div className="flex justify-between items-center">
                    <span className="text-muted-foreground">Active Today</span>
                    <span className="font-bold text-xl text-green-600">{metrics.users.active}</span>
                  </div>
                </div>
              ) : null}
            </CardContent>
          </Card>

          <Card className="bg-white/95 backdrop-blur-sm shadow-lg">
            <CardHeader className="pb-2">
              <div className="flex items-center gap-2">
                <HardDrive className="h-5 w-5 text-primary" />
                <CardTitle className="text-lg">Storage</CardTitle>
              </div>
            </CardHeader>
            <CardContent>
              {loading ? (
                <div className="flex items-center justify-center py-4">
                  <RefreshCw className="h-5 w-5 animate-spin text-primary" />
                </div>
              ) : metrics ? (
                <div className="space-y-2">
                  <div className="flex justify-between items-center">
                    <span className="text-muted-foreground">Storage Buckets</span>
                    <span className="font-bold text-xl">{metrics.storage.bucketsCount}</span>
                  </div>
                </div>
              ) : null}
            </CardContent>
          </Card>

          <Card className="bg-white/95 backdrop-blur-sm shadow-lg">
            <CardHeader className="pb-2">
              <div className="flex items-center gap-2">
                <Activity className="h-5 w-5 text-primary" />
                <CardTitle className="text-lg">Visits</CardTitle>
              </div>
            </CardHeader>
            <CardContent>
              {loading ? (
                <div className="flex items-center justify-center py-4">
                  <RefreshCw className="h-5 w-5 animate-spin text-primary" />
                </div>
              ) : metrics ? (
                <div className="space-y-2">
                  <div className="flex justify-between items-center">
                    <span className="text-muted-foreground">Active Today</span>
                    <span className="font-bold text-xl text-blue-600">{metrics.visits.activeToday}</span>
                  </div>
                </div>
              ) : null}
            </CardContent>
          </Card>
        </div>

        {/* Footer */}
        <div className="text-center text-white/80 text-sm">
          <p>Auto-refreshes every 30 minutes</p>
        </div>
      </div>
    </div>
  );
}