import { useState } from "react";
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { useMutation } from "@tanstack/react-query";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { InputOTP, InputOTPGroup, InputOTPSlot } from "@/components/ui/input-otp";
import { useToast } from "@/hooks/use-toast";
import { apiRequest } from "@/lib/queryClient";
import { loginSchema, otpRequestSchema, type LoginInput, type OtpRequestInput, type AuthResponse } from "@shared/schema";
import { Container, Lock, Mail, Phone, User, Loader2, Building2, Info } from "lucide-react";

interface LoginPageProps {
  onLoginSuccess: () => void;
}

interface OtpResponse extends AuthResponse {
  demoOtp?: string;
}

export function LoginPage({ onLoginSuccess }: LoginPageProps) {
  const { toast } = useToast();
  const [otpSent, setOtpSent] = useState(false);
  const [otp, setOtp] = useState("");
  const [phoneForOtp, setPhoneForOtp] = useState("");
  const [demoOtp, setDemoOtp] = useState<string | null>(null);

  // Username/password login form
  const loginForm = useForm<LoginInput>({
    resolver: zodResolver(loginSchema),
    defaultValues: {
      username: "",
      password: "",
    },
  });

  // OTP request form
  const otpForm = useForm<OtpRequestInput>({
    resolver: zodResolver(otpRequestSchema),
    defaultValues: {
      phone: "",
      email: "",
    },
  });

  // Login mutation
  const loginMutation = useMutation({
    mutationFn: async (data: LoginInput) => {
      const response = await apiRequest("POST", "/api/auth/login", data);
      return response.json() as Promise<AuthResponse>;
    },
    onSuccess: (data) => {
      if (data.success) {
        toast({ title: "Login successful", description: `Welcome back!` });
        onLoginSuccess();
      } else {
        toast({ title: "Login failed", description: data.message, variant: "destructive" });
      }
    },
    onError: () => {
      toast({ title: "Login failed", description: "Invalid credentials", variant: "destructive" });
    },
  });

  // Request OTP mutation
  const requestOtpMutation = useMutation({
    mutationFn: async (data: OtpRequestInput) => {
      const response = await apiRequest("POST", "/api/auth/request-otp", data);
      return response.json() as Promise<OtpResponse>;
    },
    onSuccess: (data) => {
      if (data.success) {
        setOtpSent(true);
        setPhoneForOtp(otpForm.getValues("phone"));
        if (data.demoOtp) {
          setDemoOtp(data.demoOtp);
        }
        toast({ title: "OTP Sent", description: "Check your phone and email for the OTP" });
      } else {
        toast({ title: "Failed to send OTP", description: data.message, variant: "destructive" });
      }
    },
    onError: () => {
      toast({ title: "Error", description: "Failed to send OTP. Please try again.", variant: "destructive" });
    },
  });

  // Verify OTP mutation
  const verifyOtpMutation = useMutation({
    mutationFn: async () => {
      const response = await apiRequest("POST", "/api/auth/verify-otp", { phone: phoneForOtp, otp });
      return response.json() as Promise<AuthResponse>;
    },
    onSuccess: (data) => {
      if (data.success) {
        toast({ title: "Verification successful", description: "Welcome!" });
        onLoginSuccess();
      } else {
        toast({ title: "Verification failed", description: data.message, variant: "destructive" });
      }
    },
    onError: () => {
      toast({ title: "Verification failed", description: "Invalid OTP", variant: "destructive" });
    },
  });

  const handleLoginSubmit = (data: LoginInput) => {
    loginMutation.mutate(data);
  };

  const handleOtpRequest = (data: OtpRequestInput) => {
    requestOtpMutation.mutate(data);
  };

  const handleOtpVerify = () => {
    if (otp.length === 6) {
      verifyOtpMutation.mutate();
    }
  };

  return (
    <div className="min-h-screen flex items-center justify-center bg-gradient-to-br from-background via-muted/30 to-background p-4">
      <div className="w-full max-w-md">
        {/* Company Header */}
        <div className="text-center mb-8">
          <div className="inline-flex items-center justify-center w-16 h-16 rounded-2xl bg-primary text-primary-foreground mb-4 shadow-lg">
            <Container className="w-8 h-8" />
          </div>
          <h1 className="text-2xl font-bold tracking-tight">Container Location Update</h1>
          <div className="flex items-center justify-center gap-2 mt-2 text-muted-foreground">
            <Building2 className="w-4 h-4" />
            <span className="text-sm">Indev Infra Private Ltd, Mumbai</span>
          </div>
        </div>

        <Card className="shadow-xl border-border/50">
          <CardHeader className="space-y-1 pb-4">
            <CardTitle className="text-xl font-semibold text-center">Sign In</CardTitle>
            <CardDescription className="text-center">
              Access the container management system
            </CardDescription>
          </CardHeader>
          <CardContent>
            <Tabs defaultValue="credentials" className="w-full">
              <TabsList className="grid w-full grid-cols-2 mb-6">
                <TabsTrigger value="credentials" data-testid="tab-credentials" className="gap-2">
                  <User className="w-4 h-4" />
                  Credentials
                </TabsTrigger>
                <TabsTrigger value="otp" data-testid="tab-otp" className="gap-2">
                  <Phone className="w-4 h-4" />
                  OTP
                </TabsTrigger>
              </TabsList>

              {/* Username/Password Tab */}
              <TabsContent value="credentials">
                <form onSubmit={loginForm.handleSubmit(handleLoginSubmit)} className="space-y-4">
                  <div className="space-y-2">
                    <Label htmlFor="username">Username</Label>
                    <div className="relative">
                      <User className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-muted-foreground" />
                      <Input
                        id="username"
                        placeholder="Enter your username"
                        className="pl-10"
                        data-testid="input-username"
                        {...loginForm.register("username")}
                      />
                    </div>
                    {loginForm.formState.errors.username && (
                      <p className="text-sm text-destructive">{loginForm.formState.errors.username.message}</p>
                    )}
                  </div>
                  <div className="space-y-2">
                    <Label htmlFor="password">Password</Label>
                    <div className="relative">
                      <Lock className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-muted-foreground" />
                      <Input
                        id="password"
                        type="password"
                        placeholder="Enter your password"
                        className="pl-10"
                        data-testid="input-password"
                        {...loginForm.register("password")}
                      />
                    </div>
                    {loginForm.formState.errors.password && (
                      <p className="text-sm text-destructive">{loginForm.formState.errors.password.message}</p>
                    )}
                  </div>
                  
                  {/* Demo credentials hint */}
                  <div className="flex items-center gap-2 p-3 bg-muted/50 rounded-md text-sm text-muted-foreground">
                    <Info className="w-4 h-4 flex-shrink-0" />
                    <span>Demo: username <strong>admin</strong>, password <strong>admin123</strong></span>
                  </div>
                  
                  <Button 
                    type="submit" 
                    className="w-full" 
                    disabled={loginMutation.isPending}
                    data-testid="button-login"
                  >
                    {loginMutation.isPending ? (
                      <>
                        <Loader2 className="w-4 h-4 mr-2 animate-spin" />
                        Signing in...
                      </>
                    ) : (
                      "Sign In"
                    )}
                  </Button>
                </form>
              </TabsContent>

              {/* OTP Tab */}
              <TabsContent value="otp">
                {!otpSent ? (
                  <form onSubmit={otpForm.handleSubmit(handleOtpRequest)} className="space-y-4">
                    <div className="space-y-2">
                      <Label htmlFor="phone">Mobile Number</Label>
                      <div className="relative">
                        <Phone className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-muted-foreground" />
                        <Input
                          id="phone"
                          placeholder="+91 9876543210"
                          className="pl-10"
                          data-testid="input-phone"
                          {...otpForm.register("phone")}
                        />
                      </div>
                      {otpForm.formState.errors.phone && (
                        <p className="text-sm text-destructive">{otpForm.formState.errors.phone.message}</p>
                      )}
                    </div>
                    <div className="space-y-2">
                      <Label htmlFor="email">Email Address</Label>
                      <div className="relative">
                        <Mail className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-muted-foreground" />
                        <Input
                          id="email"
                          type="email"
                          placeholder="you@company.com"
                          className="pl-10"
                          data-testid="input-email"
                          {...otpForm.register("email")}
                        />
                      </div>
                      {otpForm.formState.errors.email && (
                        <p className="text-sm text-destructive">{otpForm.formState.errors.email.message}</p>
                      )}
                    </div>
                    <Button 
                      type="submit" 
                      className="w-full" 
                      disabled={requestOtpMutation.isPending}
                      data-testid="button-request-otp"
                    >
                      {requestOtpMutation.isPending ? (
                        <>
                          <Loader2 className="w-4 h-4 mr-2 animate-spin" />
                          Sending OTP...
                        </>
                      ) : (
                        "Request OTP"
                      )}
                    </Button>
                  </form>
                ) : (
                  <div className="space-y-6">
                    <div className="text-center">
                      <p className="text-sm text-muted-foreground mb-4">
                        Enter the 6-digit OTP sent to your phone and email
                      </p>
                      
                      {/* Demo OTP display */}
                      {demoOtp && (
                        <div className="flex items-center justify-center gap-2 p-3 mb-4 bg-accent/20 rounded-md text-sm">
                          <Info className="w-4 h-4 text-accent-foreground" />
                          <span>Demo OTP: <strong className="font-mono">{demoOtp}</strong></span>
                        </div>
                      )}
                      
                      <div className="flex justify-center">
                        <InputOTP 
                          maxLength={6} 
                          value={otp} 
                          onChange={(value) => setOtp(value)}
                          data-testid="input-otp"
                        >
                          <InputOTPGroup>
                            <InputOTPSlot index={0} />
                            <InputOTPSlot index={1} />
                            <InputOTPSlot index={2} />
                            <InputOTPSlot index={3} />
                            <InputOTPSlot index={4} />
                            <InputOTPSlot index={5} />
                          </InputOTPGroup>
                        </InputOTP>
                      </div>
                    </div>
                    <div className="space-y-2">
                      <Button 
                        onClick={handleOtpVerify} 
                        className="w-full" 
                        disabled={otp.length !== 6 || verifyOtpMutation.isPending}
                        data-testid="button-verify-otp"
                      >
                        {verifyOtpMutation.isPending ? (
                          <>
                            <Loader2 className="w-4 h-4 mr-2 animate-spin" />
                            Verifying...
                          </>
                        ) : (
                          "Verify OTP"
                        )}
                      </Button>
                      <Button 
                        type="button"
                        variant="ghost" 
                        className="w-full" 
                        onClick={() => {
                          setOtpSent(false);
                          setDemoOtp(null);
                          setOtp("");
                        }}
                        data-testid="button-back-otp"
                      >
                        Back
                      </Button>
                    </div>
                  </div>
                )}
              </TabsContent>
            </Tabs>
          </CardContent>
        </Card>

        <p className="text-center text-xs text-muted-foreground mt-6">
          Secure access to container management system
        </p>
      </div>
    </div>
  );
}
