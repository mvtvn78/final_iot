import { Outlet } from "react-router-dom";
import Footer from "./footer";
import Menu from "./menu";

export default function DefaultLayout() {
  return (
    <>
      <div>
        <div className="flex">
          <div className="w-[298px]">
            <Menu />
          </div>
          <div className="flex-1">
            {/* <Header /> */}
            <div className="flex">
              <Outlet />
            </div>
          </div>
        </div>
        <Footer />
      </div>
    </>
  );
}
