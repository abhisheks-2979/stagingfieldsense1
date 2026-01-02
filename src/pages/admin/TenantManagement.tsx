import { useState, useEffect } from 'react';
import { supabase } from '@/integrations/supabase/client';
import { Layout } from '@/components/Layout';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Badge } from '@/components/ui/badge';
import { toast } from 'sonner';
import { Building2, Users, Plus, UserPlus, Crown, Shield, User } from 'lucide-react';
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogTrigger } from '@/components/ui/dialog';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select';

interface Tenant {
  id: string;
  name: string;
  slug: string;
  logo_url: string | null;
  is_active: boolean;
  created_at: string;
}

interface TenantUser {
  id: string;
  tenant_id: string;
  user_id: string;
  role: 'owner' | 'admin' | 'member';
  created_at: string;
  profiles?: {
    full_name: string;
    username: string;
  };
}

const TenantManagement = () => {
  const [tenants, setTenants] = useState<Tenant[]>([]);
  const [selectedTenant, setSelectedTenant] = useState<Tenant | null>(null);
  const [tenantUsers, setTenantUsers] = useState<TenantUser[]>([]);
  const [loading, setLoading] = useState(true);
  const [showCreateDialog, setShowCreateDialog] = useState(false);
  const [showAddUserDialog, setShowAddUserDialog] = useState(false);
  const [newTenantName, setNewTenantName] = useState('');
  const [availableUsers, setAvailableUsers] = useState<any[]>([]);
  const [selectedUserId, setSelectedUserId] = useState('');
  const [selectedRole, setSelectedRole] = useState<'admin' | 'member'>('member');

  useEffect(() => {
    fetchTenants();
  }, []);

  useEffect(() => {
    if (selectedTenant) {
      fetchTenantUsers(selectedTenant.id);
    }
  }, [selectedTenant]);

  const fetchTenants = async () => {
    try {
      const { data, error } = await supabase
        .from('tenants')
        .select('*')
        .order('created_at', { ascending: false });

      if (error) throw error;
      setTenants(data || []);
      if (data && data.length > 0 && !selectedTenant) {
        setSelectedTenant(data[0]);
      }
    } catch (error) {
      console.error('Error fetching tenants:', error);
      toast.error('Failed to load tenants');
    } finally {
      setLoading(false);
    }
  };

  const fetchTenantUsers = async (tenantId: string) => {
    try {
      // First get tenant users
      const { data: tuData, error: tuError } = await supabase
        .from('tenant_users')
        .select('*')
        .eq('tenant_id', tenantId)
        .order('role', { ascending: true });

      if (tuError) throw tuError;

      // Then get profiles for each user
      const userIds = (tuData || []).map(tu => tu.user_id);
      const { data: profiles } = await supabase
        .from('profiles')
        .select('id, full_name, username')
        .in('id', userIds);

      // Combine the data
      const combined = (tuData || []).map(tu => ({
        ...tu,
        profiles: profiles?.find(p => p.id === tu.user_id) || { full_name: 'Unknown', username: 'unknown' }
      }));

      setTenantUsers(combined);
    } catch (error) {
      console.error('Error fetching tenant users:', error);
    }
  };

  const fetchAvailableUsers = async () => {
    try {
      // Get all profiles that are not in the selected tenant
      const { data: allProfiles, error } = await supabase
        .from('profiles')
        .select('id, full_name, username');

      if (error) throw error;

      const existingUserIds = tenantUsers.map(tu => tu.user_id);
      const available = (allProfiles || []).filter(p => !existingUserIds.includes(p.id));
      setAvailableUsers(available);
    } catch (error) {
      console.error('Error fetching available users:', error);
    }
  };

  const createTenant = async () => {
    if (!newTenantName.trim()) {
      toast.error('Please enter a tenant name');
      return;
    }

    try {
      const slug = newTenantName.toLowerCase().replace(/\s+/g, '-').replace(/[^a-z0-9-]/g, '');
      
      const { data, error } = await supabase
        .from('tenants')
        .insert({ name: newTenantName, slug, is_active: true })
        .select()
        .single();

      if (error) throw error;

      toast.success('Tenant created successfully');
      setShowCreateDialog(false);
      setNewTenantName('');
      fetchTenants();
      setSelectedTenant(data);
    } catch (error: any) {
      console.error('Error creating tenant:', error);
      toast.error(error.message || 'Failed to create tenant');
    }
  };

  const addUserToTenant = async () => {
    if (!selectedUserId || !selectedTenant) {
      toast.error('Please select a user');
      return;
    }

    try {
      const { error } = await supabase
        .from('tenant_users')
        .insert({
          tenant_id: selectedTenant.id,
          user_id: selectedUserId,
          role: selectedRole
        });

      if (error) throw error;

      // Also update the user's profile with the tenant_id
      await supabase
        .from('profiles')
        .update({ tenant_id: selectedTenant.id })
        .eq('id', selectedUserId);

      toast.success('User added to tenant');
      setShowAddUserDialog(false);
      setSelectedUserId('');
      setSelectedRole('member');
      fetchTenantUsers(selectedTenant.id);
    } catch (error: any) {
      console.error('Error adding user to tenant:', error);
      toast.error(error.message || 'Failed to add user');
    }
  };

  const updateUserRole = async (tenantUserId: string, newRole: 'owner' | 'admin' | 'member') => {
    try {
      const { error } = await supabase
        .from('tenant_users')
        .update({ role: newRole })
        .eq('id', tenantUserId);

      if (error) throw error;

      toast.success('Role updated');
      if (selectedTenant) {
        fetchTenantUsers(selectedTenant.id);
      }
    } catch (error) {
      console.error('Error updating role:', error);
      toast.error('Failed to update role');
    }
  };

  const removeUserFromTenant = async (tenantUserId: string, userId: string) => {
    try {
      const { error } = await supabase
        .from('tenant_users')
        .delete()
        .eq('id', tenantUserId);

      if (error) throw error;

      // Clear tenant_id from profile
      await supabase
        .from('profiles')
        .update({ tenant_id: null })
        .eq('id', userId);

      toast.success('User removed from tenant');
      if (selectedTenant) {
        fetchTenantUsers(selectedTenant.id);
      }
    } catch (error) {
      console.error('Error removing user:', error);
      toast.error('Failed to remove user');
    }
  };

  const getRoleIcon = (role: string) => {
    switch (role) {
      case 'owner': return <Crown className="h-4 w-4 text-amber-500" />;
      case 'admin': return <Shield className="h-4 w-4 text-blue-500" />;
      default: return <User className="h-4 w-4 text-muted-foreground" />;
    }
  };

  const getRoleBadgeVariant = (role: string) => {
    switch (role) {
      case 'owner': return 'default';
      case 'admin': return 'secondary';
      default: return 'outline';
    }
  };

  if (loading) {
    return (
      <Layout>
        <div className="flex items-center justify-center h-64">
          <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-primary" />
        </div>
      </Layout>
    );
  }

  return (
    <Layout>
      <div className="space-y-6 p-4">
        <div className="flex items-center justify-between">
          <div>
            <h1 className="text-2xl font-bold">Tenant Management</h1>
            <p className="text-muted-foreground">Manage organizations and their users</p>
          </div>
          <Dialog open={showCreateDialog} onOpenChange={setShowCreateDialog}>
            <DialogTrigger asChild>
              <Button>
                <Plus className="h-4 w-4 mr-2" />
                New Tenant
              </Button>
            </DialogTrigger>
            <DialogContent>
              <DialogHeader>
                <DialogTitle>Create New Tenant</DialogTitle>
              </DialogHeader>
              <div className="space-y-4 pt-4">
                <div>
                  <Label htmlFor="tenantName">Tenant Name</Label>
                  <Input
                    id="tenantName"
                    value={newTenantName}
                    onChange={(e) => setNewTenantName(e.target.value)}
                    placeholder="Enter tenant name"
                  />
                </div>
                <Button onClick={createTenant} className="w-full">
                  Create Tenant
                </Button>
              </div>
            </DialogContent>
          </Dialog>
        </div>

        <div className="grid gap-6 lg:grid-cols-3">
          {/* Tenant List */}
          <Card className="lg:col-span-1">
            <CardHeader>
              <CardTitle className="flex items-center gap-2">
                <Building2 className="h-5 w-5" />
                Tenants
              </CardTitle>
            </CardHeader>
            <CardContent className="space-y-2">
              {tenants.map((tenant) => (
                <div
                  key={tenant.id}
                  onClick={() => setSelectedTenant(tenant)}
                  className={`p-3 rounded-lg cursor-pointer transition-colors ${
                    selectedTenant?.id === tenant.id
                      ? 'bg-primary/10 border border-primary'
                      : 'bg-muted/50 hover:bg-muted'
                  }`}
                >
                  <div className="flex items-center justify-between">
                    <span className="font-medium">{tenant.name}</span>
                    <Badge variant={tenant.is_active ? 'default' : 'secondary'}>
                      {tenant.is_active ? 'Active' : 'Inactive'}
                    </Badge>
                  </div>
                  <p className="text-xs text-muted-foreground mt-1">{tenant.slug}</p>
                </div>
              ))}
              {tenants.length === 0 && (
                <p className="text-center text-muted-foreground py-4">
                  No tenants found
                </p>
              )}
            </CardContent>
          </Card>

          {/* Tenant Details & Users */}
          <Card className="lg:col-span-2">
            {selectedTenant ? (
              <>
                <CardHeader>
                  <div className="flex items-center justify-between">
                    <CardTitle className="flex items-center gap-2">
                      <Users className="h-5 w-5" />
                      {selectedTenant.name} - Users
                    </CardTitle>
                    <Dialog open={showAddUserDialog} onOpenChange={(open) => {
                      setShowAddUserDialog(open);
                      if (open) fetchAvailableUsers();
                    }}>
                      <DialogTrigger asChild>
                        <Button size="sm">
                          <UserPlus className="h-4 w-4 mr-2" />
                          Add User
                        </Button>
                      </DialogTrigger>
                      <DialogContent>
                        <DialogHeader>
                          <DialogTitle>Add User to {selectedTenant.name}</DialogTitle>
                        </DialogHeader>
                        <div className="space-y-4 pt-4">
                          <div>
                            <Label>Select User</Label>
                            <Select value={selectedUserId} onValueChange={setSelectedUserId}>
                              <SelectTrigger>
                                <SelectValue placeholder="Choose a user" />
                              </SelectTrigger>
                              <SelectContent>
                                {availableUsers.map((user) => (
                                  <SelectItem key={user.id} value={user.id}>
                                    {user.full_name || user.username}
                                  </SelectItem>
                                ))}
                              </SelectContent>
                            </Select>
                          </div>
                          <div>
                            <Label>Role</Label>
                            <Select value={selectedRole} onValueChange={(v: 'admin' | 'member') => setSelectedRole(v)}>
                              <SelectTrigger>
                                <SelectValue />
                              </SelectTrigger>
                              <SelectContent>
                                <SelectItem value="admin">Admin</SelectItem>
                                <SelectItem value="member">Member</SelectItem>
                              </SelectContent>
                            </Select>
                          </div>
                          <Button onClick={addUserToTenant} className="w-full">
                            Add to Tenant
                          </Button>
                        </div>
                      </DialogContent>
                    </Dialog>
                  </div>
                </CardHeader>
                <CardContent>
                  <div className="space-y-3">
                    {tenantUsers.map((tu) => (
                      <div key={tu.id} className="flex items-center justify-between p-3 bg-muted/50 rounded-lg">
                        <div className="flex items-center gap-3">
                          {getRoleIcon(tu.role)}
                          <div>
                            <p className="font-medium">
                              {tu.profiles?.full_name || tu.profiles?.username || 'Unknown User'}
                            </p>
                            <Badge variant={getRoleBadgeVariant(tu.role) as any} className="mt-1">
                              {tu.role}
                            </Badge>
                          </div>
                        </div>
                        <div className="flex items-center gap-2">
                          <Select
                            value={tu.role}
                            onValueChange={(v: 'owner' | 'admin' | 'member') => updateUserRole(tu.id, v)}
                          >
                            <SelectTrigger className="w-28">
                              <SelectValue />
                            </SelectTrigger>
                            <SelectContent>
                              <SelectItem value="owner">Owner</SelectItem>
                              <SelectItem value="admin">Admin</SelectItem>
                              <SelectItem value="member">Member</SelectItem>
                            </SelectContent>
                          </Select>
                          {tu.role !== 'owner' && (
                            <Button
                              variant="ghost"
                              size="sm"
                              className="text-destructive"
                              onClick={() => removeUserFromTenant(tu.id, tu.user_id)}
                            >
                              Remove
                            </Button>
                          )}
                        </div>
                      </div>
                    ))}
                    {tenantUsers.length === 0 && (
                      <p className="text-center text-muted-foreground py-8">
                        No users in this tenant. Add users to get started.
                      </p>
                    )}
                  </div>
                </CardContent>
              </>
            ) : (
              <CardContent className="flex items-center justify-center h-64">
                <p className="text-muted-foreground">Select a tenant to view details</p>
              </CardContent>
            )}
          </Card>
        </div>
      </div>
    </Layout>
  );
};

export default TenantManagement;
