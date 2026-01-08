import type { RouteObject } from "react-router-dom";
import { Navigate } from "react-router-dom";

export const dashboardRoutes: RouteObject[] = [
  {
    path: "",
    element: <Navigate to="/spaces" replace />,
  },
];
