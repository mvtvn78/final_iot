// Logger Service - Centralized logging with environment awareness

type LogLevel = "log" | "warn" | "error" | "info" | "debug";

class Logger {
  private isDevelopment: boolean;

  constructor() {
    this.isDevelopment = import.meta.env.DEV || process.env.NODE_ENV === "development";
  }

  private formatMessage(level: LogLevel, message: string, ...args: unknown[]): void {
    const timestamp = new Date().toISOString();
    const prefix = `[${timestamp}] [${level.toUpperCase()}]`;

    if (this.isDevelopment) {
      switch (level) {
        case "log":
          console.log(prefix, message, ...args);
          break;
        case "info":
          console.info(prefix, message, ...args);
          break;
        case "warn":
          console.warn(prefix, message, ...args);
          break;
        case "error":
          console.error(prefix, message, ...args);
          break;
        case "debug":
          console.debug(prefix, message, ...args);
          break;
      }
    } else {
      // In production, only log errors and warnings
      if (level === "error" || level === "warn") {
        console[level](prefix, message, ...args);
      }
    }
  }

  log(message: string, ...args: unknown[]): void {
    this.formatMessage("log", message, ...args);
  }

  info(message: string, ...args: unknown[]): void {
    this.formatMessage("info", message, ...args);
  }

  warn(message: string, ...args: unknown[]): void {
    this.formatMessage("warn", message, ...args);
  }

  error(message: string, ...args: unknown[]): void {
    this.formatMessage("error", message, ...args);
  }

  debug(message: string, ...args: unknown[]): void {
    this.formatMessage("debug", message, ...args);
  }
}

export const logger = new Logger();

