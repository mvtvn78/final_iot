import axios, { AxiosError, type AxiosRequestConfig } from "axios";
import { API_CONFIG, STORAGE_KEYS } from "../constants";
import { openNotification } from "../components/base/notification";

export const BASE_API = axios.create({
  baseURL: API_CONFIG.BASE_URL,
  timeout: API_CONFIG.TIMEOUT,
  headers: {
    "Content-Type": "application/json",
    Accept: "application/json",
  },
});

// Request interceptor - Add token to requests
BASE_API.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem(STORAGE_KEYS.TOKEN);
    if (token && config.headers) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error) => {
    return Promise.reject(error);
  }
);

// Response interceptor - Handle errors globally
BASE_API.interceptors.response.use(
  (response) => {
    return response;
  },
  (error: AxiosError) => {
    // Handle network errors
    if (!error.response) {
      openNotification({
        type: "error",
        title: "Network Error",
        message: "Please check your internet connection and try again.",
      });
      return Promise.reject(error);
    }

    // Handle HTTP errors
    const status = error.response.status;
    const message = (error.response.data as { message?: string })?.message || "An error occurred";

    switch (status) {
      case 401:
        // Unauthorized - Clear token and redirect to login
        localStorage.removeItem(STORAGE_KEYS.TOKEN);
        openNotification({
          type: "error",
          title: "Session Expired",
          message: "Please login again.",
        });
        // Redirect to login after a short delay
        setTimeout(() => {
          window.location.href = "/login";
        }, 1000);
        break;
      case 403:
        openNotification({
          type: "error",
          title: "Access Denied",
          message: "You don't have permission to perform this action.",
        });
        break;
      case 404:
        openNotification({
          type: "error",
          title: "Not Found",
          message: "The requested resource was not found.",
        });
        break;
      case 500:
      case 502:
      case 503:
        openNotification({
          type: "error",
          title: "Server Error",
          message: "The server is experiencing issues. Please try again later.",
        });
        break;
      default:
        openNotification({
          type: "error",
          title: "Error",
          message: message || "Something went wrong. Please try again.",
        });
    }

    return Promise.reject(error);
  }
);
  