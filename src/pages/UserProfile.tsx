import React, { useState, useEffect } from 'react';
import { useAuth } from '@/hooks/useAuth';
import { supabase } from '@/integrations/supabase/client';
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs';
import { useToast } from '@/hooks/use-toast';
import { Loader2, User, Trophy, TrendingUp, Users, Bell } from 'lucide-react';
import { Navigate } from 'react-router-dom';
import { BadgesDisplay } from '@/components/BadgesDisplay';
import { PointsDetailsModal } from '@/components/PointsDetailsModal';
import { PerformanceDashboard } from '@/components/profile/PerformanceDashboard';
import { InstagramSocialFeed } from '@/components/profile/InstagramSocialFeed';
import { PushContentConfigurator } from '@/components/profile/PushContentConfigurator';
import { ProfileAttachments } from '@/components/profile/ProfileAttachments';
import { Layout } from '@/components/Layout';
import { AboutViewMode } from '@/components/profile/about/AboutViewMode';
import { AboutEditMode } from '@/components/profile/about/AboutEditMode';
import { WorkExperienceSection } from '@/components/profile/about/WorkExperienceSection';
import { EducationHistorySection } from '@/components/profile/about/EducationHistorySection';
import { OnboardingChecklistSection } from '@/components/profile/about/OnboardingChecklistSection';

interface Manager {
  id: string;
  full_name: string;
}

interface Territory {
  id: string;
  name: string;
}

const UserProfile = () => {
  const { user, userProfile } = useAuth();
  const { toast } = useToast();
  const [loading, setLoading] = useState(false);
  const [managers, setManagers] = useState<Manager[]>([]);
  const [territories, setTerritories] = useState<Territory[]>([]);
  const [pointsModalOpen, setPointsModalOpen] = useState(false);
  const [totalPoints, setTotalPoints] = useState(0);
  const [isEditing, setIsEditing] = useState(false);
  
  const [formData, setFormData] = useState({
    username: '',
    full_name: '',
    phone_number: '',
    recovery_email: '',
    email: '',
    monthly_salary: '',
    daily_da_allowance: '',
    manager_id: '',
    hq: '',
    hq_territory_id: '',
    date_of_joining: '',
    date_of_exit: '',
    alternate_email: '',
    address: '',
    education: '',
    emergency_contact_number: '',
    band: '',
    designation: '',
    linkedin_url: '',
    twitter_url: '',
    instagram_url: '',
    facebook_url: ''
  });

  useEffect(() => {
    if (userProfile && user) {
      fetchManagers();
      fetchTerritories();
      fetchEmployeeData();
      fetchTotalPoints();
    }
  }, [userProfile, user]);

  const fetchManagers = async () => {
    const { data } = await supabase
      .from('profiles')
      .select('id, full_name')
      .order('full_name');

    if (data) {
      setManagers(data);
    }
  };

  const fetchTerritories = async () => {
    const { data } = await supabase
      .from('territories')
      .select('id, name')
      .order('name');

    if (data) {
      setTerritories(data);
    }
  };

  const fetchEmployeeData = async () => {
    if (!user) return;

    const { data: employeeData } = await supabase
      .from('employees')
      .select('*')
      .eq('user_id', user.id)
      .single();

    if (employeeData) {
      setFormData({
        username: userProfile?.username || '',
        full_name: userProfile?.full_name || '',
        phone_number: userProfile?.phone_number || '',
        recovery_email: userProfile?.recovery_email || '',
        email: user.email || '',
        monthly_salary: employeeData.monthly_salary?.toString() || '',
        daily_da_allowance: employeeData.daily_da_allowance?.toString() || '',
        manager_id: employeeData.manager_id || '',
        hq: employeeData.hq || '',
        hq_territory_id: (employeeData as any).hq_territory_id || '',
        date_of_joining: employeeData.date_of_joining || '',
        date_of_exit: employeeData.date_of_exit || '',
        alternate_email: employeeData.alternate_email || '',
        address: employeeData.address || '',
        education: employeeData.education || '',
        emergency_contact_number: employeeData.emergency_contact_number || '',
        band: (employeeData as any).band?.toString() || '',
        designation: (employeeData as any).designation || '',
        linkedin_url: (employeeData as any).linkedin_url || '',
        twitter_url: (employeeData as any).twitter_url || '',
        instagram_url: (employeeData as any).instagram_url || '',
        facebook_url: (employeeData as any).facebook_url || ''
      });
    }
  };

  const fetchTotalPoints = async () => {
    if (!user) return;

    const { data } = await supabase
      .from('gamification_points')
      .select('points')
      .eq('user_id', user.id);

    if (data) {
      const total = data.reduce((sum, record) => sum + (record.points || 0), 0);
      setTotalPoints(total);
    }
  };

  const handleProfileUpdate = async () => {
    if (!user) return;

    setLoading(true);
    try {
      // Update profile table
      const { error: profileError } = await supabase
        .from('profiles')
        .update({
          username: formData.username,
          full_name: formData.full_name,
          phone_number: formData.phone_number,
          recovery_email: formData.recovery_email
        })
        .eq('id', user.id);

      if (profileError) throw profileError;

      // Update employees table
      const { error: employeeError } = await supabase
        .from('employees')
        .upsert({
          user_id: user.id,
          monthly_salary: parseFloat(formData.monthly_salary) || 0,
          daily_da_allowance: parseFloat(formData.daily_da_allowance) || 0,
          manager_id: formData.manager_id || null,
          hq: formData.hq,
          hq_territory_id: formData.hq_territory_id || null,
          date_of_joining: formData.date_of_joining || null,
          date_of_exit: formData.date_of_exit || null,
          alternate_email: formData.alternate_email,
          address: formData.address,
          education: formData.education,
          emergency_contact_number: formData.emergency_contact_number,
          designation: formData.designation
        });

      if (employeeError) throw employeeError;

      toast({
        title: "Success",
        description: "Profile updated successfully!"
      });
      setIsEditing(false);
    } catch (error: any) {
      toast({
        title: "Error",
        description: error.message,
        variant: "destructive"
      });
    } finally {
      setLoading(false);
    }
  };

  if (!user) {
    return <Navigate to="/auth" replace />;
  }

  return (
    <Layout>
      <div className="p-4">
        <div className="max-w-6xl mx-auto space-y-6">
          <div className="flex items-center gap-4">
            <User className="w-8 h-8 text-primary" />
            <div>
              <h1 className="text-3xl font-bold text-foreground">My Profile</h1>
              <p className="text-muted-foreground">Manage your information and track performance</p>
            </div>
          </div>

          <Tabs defaultValue="about" className="space-y-4">
            <TabsList className="w-full flex flex-wrap h-auto gap-1 p-1">
              <TabsTrigger value="about" className="flex-1 min-w-[80px] text-xs sm:text-sm py-2">
                <User className="h-4 w-4 sm:mr-2" />
                <span className="hidden sm:inline">About</span>
              </TabsTrigger>
              <TabsTrigger value="performance" className="flex-1 min-w-[80px] text-xs sm:text-sm py-2">
                <TrendingUp className="h-4 w-4 sm:mr-2" />
                <span className="hidden sm:inline">Performance</span>
              </TabsTrigger>
              <TabsTrigger value="gamification" className="flex-1 min-w-[80px] text-xs sm:text-sm py-2">
                <Trophy className="h-4 w-4 sm:mr-2" />
                <span className="hidden sm:inline">Points</span>
              </TabsTrigger>
              <TabsTrigger value="social" className="flex-1 min-w-[80px] text-xs sm:text-sm py-2">
                <Users className="h-4 w-4 sm:mr-2" />
                <span className="hidden sm:inline">Social</span>
              </TabsTrigger>
              <TabsTrigger value="push-content" className="flex-1 min-w-[80px] text-xs sm:text-sm py-2">
                <Bell className="h-4 w-4 sm:mr-2" />
                <span className="hidden sm:inline">Push</span>
              </TabsTrigger>
            </TabsList>

            {/* About Tab */}
            <TabsContent value="about" className="space-y-6">
              {isEditing ? (
                <AboutEditMode
                  formData={formData}
                  setFormData={setFormData}
                  managers={managers}
                  territories={territories}
                  loading={loading}
                  onSave={handleProfileUpdate}
                  onCancel={() => setIsEditing(false)}
                />
              ) : (
                <AboutViewMode
                  userProfile={userProfile}
                  formData={formData}
                  territories={territories}
                  managers={managers}
                  onEdit={() => setIsEditing(true)}
                />
              )}

              {/* Work Experience Section */}
              <WorkExperienceSection />

              {/* Education Section */}
              <EducationHistorySection />

              {/* Onboarding Checklist Section */}
              <OnboardingChecklistSection />

              {/* Attachments Section */}
              <ProfileAttachments />
            </TabsContent>

            {/* Performance Tab */}
            <TabsContent value="performance">
              <PerformanceDashboard userId={user.id} />
            </TabsContent>

            {/* Gamification Tab */}
            <TabsContent value="gamification" className="space-y-6">
              <Card>
                <CardHeader>
                  <CardTitle className="flex items-center justify-between">
                    <span className="flex items-center gap-2">
                      <Trophy className="h-5 w-5" />
                      Gamification Points
                    </span>
                    <Button onClick={() => setPointsModalOpen(true)} variant="outline" size="sm">
                      View Details
                    </Button>
                  </CardTitle>
                </CardHeader>
                <CardContent>
                  <div className="text-center">
                    <div className="text-4xl font-bold text-primary">{totalPoints}</div>
                    <p className="text-muted-foreground mt-2">Total Points Earned</p>
                  </div>
                </CardContent>
              </Card>

              <BadgesDisplay />
            </TabsContent>

            {/* Social/Collaboration Tab */}
            <TabsContent value="social">
              <InstagramSocialFeed />
            </TabsContent>

            {/* Push Content Tab */}
            <TabsContent value="push-content">
              <PushContentConfigurator />
            </TabsContent>
          </Tabs>
          
          <PointsDetailsModal
            open={pointsModalOpen}
            onOpenChange={setPointsModalOpen}
            userId={user.id}
            timeFilter="month"
          />
        </div>
      </div>
    </Layout>
  );
};

export default UserProfile;
