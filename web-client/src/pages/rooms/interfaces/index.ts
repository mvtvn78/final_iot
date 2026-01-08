export interface Room {
  id?: string;
  name: string;
  size: number;
  unit: "m²" | "ft²";
  image?: string;
  deviceCount?: number;
}

