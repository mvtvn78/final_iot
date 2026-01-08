export interface Device {
    id: string;
    name: string;
    topicRelay: string;
    topicData: string;
}

export interface Room {
    id?: string;
    name: string;
    size: number;
    unit: "m²" | "ft²";
    image?: string;
    deviceCount?: number;
}