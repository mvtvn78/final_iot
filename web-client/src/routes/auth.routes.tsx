import React from "react";
import type { RouteObject } from "react-router-dom";
import LazyLoad from "../components/base/lazyLoad";

const LoginPage = React.lazy(() => import("../pages/login/pages"));
const RegisterPage = React.lazy(() => import("../pages/register/pages"));
const ResetPasswordPage = React.lazy(
  () => import("../pages/resetPassword/pages")
);
const VerifyCodePage = React.lazy(() => import("../pages/verifyCode/pages"));
const SuccessPage = React.lazy(() => import("../pages/success"));

const ForgetPage = React.lazy(() => import("../pages/forget/pages"));
export const authRoutes: RouteObject[] = [
  {
    path: "/login",
    element: (
      <LazyLoad>
        <LoginPage />
      </LazyLoad>
    ),
  },
  {
    path: "/register",
    element: (
      <LazyLoad>
        <RegisterPage />
      </LazyLoad>
    ),
  },
  {
    path: "/reset",
    element: (
      <LazyLoad>
        <ResetPasswordPage />
      </LazyLoad>
    ),
  },
  {
    path: "/verify-code",
    element: (
      <LazyLoad>
        <VerifyCodePage />
      </LazyLoad>
    ),
  },
  {
    path: "/success",
    element: (
      <LazyLoad>
        <SuccessPage />
      </LazyLoad>
    ),
  },

  {
    path: "/forget",
    element: (
      <LazyLoad>
        <ForgetPage />
      </LazyLoad>
    ),
  },
];
