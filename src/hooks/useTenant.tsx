import { createContext, useContext, useState, useEffect, ReactNode } from 'react';
import { supabase } from '@/integrations/supabase/client';
import { useAuth } from '@/hooks/useAuth';

interface Tenant {
  id: string;
  name: string;
  slug: string;
  logo_url: string | null;
  is_active: boolean;
}

interface TenantContextType {
  tenant: Tenant | null;
  tenantRole: 'owner' | 'admin' | 'member' | null;
  loading: boolean;
  isTenantAdmin: boolean;
  refreshTenant: () => Promise<void>;
}

const TenantContext = createContext<TenantContextType | undefined>(undefined);

export const useTenant = () => {
  const context = useContext(TenantContext);
  if (context === undefined) {
    throw new Error('useTenant must be used within a TenantProvider');
  }
  return context;
};

export const TenantProvider = ({ children }: { children: ReactNode }) => {
  const { user } = useAuth();
  const [tenant, setTenant] = useState<Tenant | null>(null);
  const [tenantRole, setTenantRole] = useState<'owner' | 'admin' | 'member' | null>(null);
  const [loading, setLoading] = useState(true);

  const fetchTenantInfo = async () => {
    if (!user) {
      setTenant(null);
      setTenantRole(null);
      setLoading(false);
      return;
    }

    try {
      // Get user's tenant membership
      const { data: tenantUser, error: tuError } = await supabase
        .from('tenant_users')
        .select(`
          role,
          tenants:tenant_id (
            id,
            name,
            slug,
            logo_url,
            is_active
          )
        `)
        .eq('user_id', user.id)
        .single();

      if (tuError) {
        if (tuError.code !== 'PGRST116') { // Not found is ok
          console.error('Error fetching tenant info:', tuError);
        }
        setTenant(null);
        setTenantRole(null);
      } else if (tenantUser) {
        setTenant(tenantUser.tenants as unknown as Tenant);
        setTenantRole(tenantUser.role as 'owner' | 'admin' | 'member');
      }
    } catch (error) {
      console.error('Error in fetchTenantInfo:', error);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchTenantInfo();
  }, [user]);

  const isTenantAdmin = tenantRole === 'owner' || tenantRole === 'admin';

  return (
    <TenantContext.Provider value={{
      tenant,
      tenantRole,
      loading,
      isTenantAdmin,
      refreshTenant: fetchTenantInfo,
    }}>
      {children}
    </TenantContext.Provider>
  );
};
