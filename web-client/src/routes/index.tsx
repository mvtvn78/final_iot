import React from "react";
import { createBrowserRouter } from "react-router-dom";
import LazyLoad from "../components/base/lazyLoad";
import DefaultLayout from "../layout/DefaultLayout";
import { authRoutes } from "./auth.routes";
import { dashboardRoutes } from "./dashboarch.routes";

const SplashPage = React.lazy(() => import("../pages/splash/pages"));

const RoomsPage = React.lazy(() => import("../pages/rooms/pages/index"));
const DevicesPage = React.lazy(() => import("../pages/devices/pages/index"));
const MembersPage = React.lazy(() => import("../pages/members/pages/index"));
const StatisticsPage = React.lazy(
  () => import("../pages/statistics/pages/index")
);
const SpacesPage = React.lazy(() => import("../pages/spaces/pages/index"));
const ProfilePage = React.lazy(() => import("../pages/profile/pages/index"));
const NoDevicePage = React.lazy(() => import("../pages/noDevices"));
const NewHomePage = React.lazy(() => import("../pages/newHome"));
const AddRoomPage = React.lazy(() => import("../pages/addRoom/pages"));
const AddDevicesPage = React.lazy(
  () => import("../pages/addDevices/pages/index")
);
const LinkDevicePage = React.lazy(
  () => import("../pages/linkDevice/pages/index")
);
const DeviceDetailPage = React.lazy(
  () => import("../pages/deviceDetail/pages/index")
);

const routers = createBrowserRouter([
  {
    path: "/",
    element: (
      <LazyLoad>
        <SplashPage />
      </LazyLoad>
    ),
  },
  {
    path: "/rooms",
    element: (
      <LazyLoad>
        <RoomsPage />
      </LazyLoad>
    ),
  },
  {
    path: "/devices",
    element: (
      <LazyLoad>
        <DevicesPage />
      </LazyLoad>
    ),
  },
  {
    path: "/members",
    element: (
      <LazyLoad>
        <MembersPage />
      </LazyLoad>
    ),
  },
  {
    path: "/statistics",
    element: (
      <LazyLoad>
        <StatisticsPage />
      </LazyLoad>
    ),
  },
  {
    path: "/spaces",
    element: (
      <LazyLoad>
        <SpacesPage />
      </LazyLoad>
    ),
  },
  {
    path: "/spaces/no-device",
    element: (
      <LazyLoad>
        <NoDevicePage />
      </LazyLoad>
    ),
  },
  {
    path: "/spaces/new-home",
    element: (
      <LazyLoad>
        <NewHomePage />
      </LazyLoad>
    ),
  },
  {
    path: "/spaces/add-room",
    element: (
      <LazyLoad>
        <AddRoomPage />
      </LazyLoad>
    ),
  },
  {
    path: "/spaces/add-devices",
    element: (
      <LazyLoad>
        <AddDevicesPage />
      </LazyLoad>
    ),
  },
  {
    path: "/spaces/link-device/:id",
    element: (
      <LazyLoad>
        <LinkDevicePage />
      </LazyLoad>
    ),
  },
  {
    path: "/profile",
    element: (
      <LazyLoad>
        <ProfilePage />
      </LazyLoad>
    ),
  },
  {
    path: "/device/:deviceId",
    element: (
      <LazyLoad>
        <DeviceDetailPage />
      </LazyLoad>
    ),
  },
  {
    path: "",
    element: (
      <LazyLoad>
        <DefaultLayout />
      </LazyLoad>
    ),
    children: [...dashboardRoutes],
  },
  ...authRoutes,
]);

export default routers;
