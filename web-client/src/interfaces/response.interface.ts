export interface BaseResponse<T> {
  statusCode?: number;
  message?: string | null;
  data?: T;
}


export interface BaseResponseLogin {
  statusCode?: number;
  message?: string | null;
  data?: {
    userName: string;
    token: string;
  };
}

