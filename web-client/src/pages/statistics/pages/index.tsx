import { Select } from "antd";
import { Home } from "lucide-react";
import { useEffect, useMemo, useState } from "react";
import Menu from "../../../layout/menu";
import type { Room } from "../../addRoom/interfaces";

type TimeRange = "today" | "week" | "month" | "year" | "quarter";

const RANGE_LABELS: { key: TimeRange; label: string }[] = [
  { key: "today", label: "Today" },
  { key: "week", label: "Week" },
  { key: "month", label: "Month" },
  { key: "year", label: "Year" },
  { key: "quarter", label: "Quarter" },
];

const MOCK_USAGE: Record<TimeRange, number[]> = {
  today: [3, 5, 4, 8, 12, 9, 7],
  week: [4, 6, 5, 17, 11, 9, 7],
  month: [6, 8, 7, 9, 10, 11, 8],
  year: [8, 9, 10, 11, 12, 10, 9],
  quarter: [7, 8, 9, 10, 9, 8, 7],
};

export default function StatisticsPage() {
  const houseName = localStorage.getItem("houseName") || "My Home";
  const [timeRange, setTimeRange] = useState<TimeRange>("week");
  const [rooms, setRooms] = useState<Room[]>([]);

  useEffect(() => {
    try {
      const storedRooms = localStorage.getItem("rooms");
      if (storedRooms) {
        setRooms(JSON.parse(storedRooms));
      }
    } catch (error) {
      console.error("Error loading rooms for statistics:", error);
    }
  }, []);

  const usageData = MOCK_USAGE[timeRange];
  const maxUsage = Math.max(...usageData);
  const totalThisWeek = 50; // mock
  const totalLoss = 30.2; // mock
  const highlightedIndex = 3;

  const chartPath = useMemo(() => {
    const points = usageData.map((value, index) => {
      const x = (index / (usageData.length - 1)) * 100;
      const normalized = value / (maxUsage || 1);
      const y = 90 - normalized * 70;
      return { x, y };
    });

    if (!points.length) return "";
    const [first, ...rest] = points;
    return [
      `M ${first.x},${first.y}`,
      ...rest.map((p) => `L ${p.x},${p.y}`),
    ].join(" ");
  }, [usageData, maxUsage]);

  const highlightedValue = usageData[highlightedIndex] ?? 0;

  return (
    <div className="flex h-screen bg-gray-50">
      {/* Sidebar */}
      <div className="w-[298px] shrink-0">
        <Menu />
      </div>

      {/* Main Content */}
      <div className="flex-1 flex flex-col overflow-hidden">
        {/* Dark header (matches other steps) */}
        <div className="relative bg-[#222833] px-8 py-6 rounded-b-2xl">
          <div className="relative flex justify-between items-start">
            <div className="flex flex-col gap-1">
              <h2 className="text-2xl font-bold text-white">Statistics</h2>
              <p className="text-sm text-white/60">
                Electricity usage overview for your home.
              </p>
            </div>

            <div className="flex flex-col items-end gap-2">
              <Select
                value={houseName}
                className="w-40"
                suffixIcon={<Home size={16} />}
                options={[{ label: houseName, value: houseName }]}
              />
            </div>
          </div>
        </div>

        {/* Main Content Area */}
        <div className="flex-1 overflow-y-auto px-8 py-6">
          {/* Top chart area */}
          <div className="bg-[#181C27] rounded-2xl shadow-lg mb-8 border border-[#2A313F] overflow-hidden">
            {/* Chart header with tabs */}
            <div className="flex items-center justify-between px-6 py-4 border-b border-white/5">
              <div>
                <p className="text-xs text-white/50">Statistics</p>
                <p className="text-lg font-semibold text-white">
                  Electricity Usage
                </p>
              </div>
              <div className="flex items-center gap-2 bg-black/20 rounded-full px-1 py-1">
                {RANGE_LABELS.map((range) => (
                  <button
                    key={range.key}
                    onClick={() => setTimeRange(range.key)}
                    className={`px-4 py-1.5 text-xs rounded-full font-medium transition-colors ${
                      timeRange === range.key
                        ? "bg-[#FEC84B] text-black"
                        : "text-white/70 hover:text-white"
                    }`}
                  >
                    {range.label}
                  </button>
                ))}
              </div>
            </div>

            {/* Chart body */}
            <div className="flex">
              {/* Line chart */}
              <div className="flex-1 px-6 py-6">
                <div className="h-64 relative">
                  {/* Y-axis labels */}
                  <div className="absolute left-0 top-2 bottom-6 flex flex-col justify-between text-xs text-white/40">
                    <span>20 kW</span>
                    <span>15 kW</span>
                    <span>10 kW</span>
                    <span>5 kW</span>
                    <span>0 kW</span>
                  </div>

                  {/* Chart SVG */}
                  <div className="h-full ml-12">
                    <svg
                      viewBox="0 0 100 100"
                      className="w-full h-full"
                      preserveAspectRatio="none"
                    >
                      {/* Gradient background */}
                      <defs>
                        <linearGradient
                          id="usageGradient"
                          x1="0"
                          y1="0"
                          x2="0"
                          y2="1"
                        >
                          <stop offset="0%" stopColor="#3B82F6" stopOpacity="0.4" />
                          <stop
                            offset="100%"
                            stopColor="#3B82F6"
                            stopOpacity="0"
                          />
                        </linearGradient>
                      </defs>

                      {/* Filled area */}
                      {chartPath && (
                        <path
                          d={`${chartPath} L 100,100 L 0,100 Z`}
                          fill="url(#usageGradient)"
                        />
                      )}

                      {/* Line */}
                      {chartPath && (
                        <path
                          d={chartPath}
                          fill="none"
                          stroke="#3B82F6"
                          strokeWidth={2}
                        />
                      )}

                      {/* Highlighted point */}
                      {(() => {
                        const index = highlightedIndex;
                        const value = usageData[index];
                        if (value === undefined) return null;
                        const x = (index / (usageData.length - 1)) * 100;
                        const normalized = value / (maxUsage || 1);
                        const y = 90 - normalized * 70;
                        return (
                          <>
                            <circle
                              cx={x}
                              cy={y}
                              r={3}
                              fill="#ffffff"
                              stroke="#2563EB"
                              strokeWidth={1.5}
                            />
                            <line
                              x1={x}
                              y1={y}
                              x2={x}
                              y2={90}
                              stroke="#3B82F6"
                              strokeDasharray="2 2"
                              strokeOpacity={0.5}
                            />
                          </>
                        );
                      })()}
                    </svg>

                    {/* Tooltip bubble */}
                    <div className="absolute inset-x-0 top-8 flex justify-center pointer-events-none">
                      <div className="bg-white px-3 py-1 rounded-full text-xs font-semibold text-gray-800 shadow-md">
                        {highlightedValue} kW
                      </div>
                    </div>

                    {/* X-axis labels */}
                    <div className="absolute bottom-0 left-12 right-4 flex justify-between text-xs text-white/40">
                      <span>M</span>
                      <span>T</span>
                      <span>W</span>
                      <span>T</span>
                      <span>F</span>
                      <span>S</span>
                      <span>S</span>
                    </div>
                  </div>
                </div>
              </div>

              {/* Right summary panel */}
              <div className="w-64 bg-black/10 border-l border-white/5 px-6 py-6 flex flex-col gap-6">
                <div className="space-y-1">
                  <p className="text-xs text-white/60">This Week</p>
                  <p className="text-3xl font-semibold text-white">
                    {totalThisWeek} kW
                  </p>
                  <p className="text-xs text-emerald-400 flex items-center gap-1">
                    <span className="inline-block w-1.5 h-1.5 rounded-full bg-emerald-400" />
                    +7.45%
                  </p>
                </div>
                <div className="space-y-1">
                  <p className="text-xs text-white/60">Total Loss</p>
                  <p className="text-3xl font-semibold text-white">
                    {totalLoss.toFixed(1)} kW
                  </p>
                  <p className="text-xs text-rose-400 flex items-center gap-1">
                    <span className="inline-block w-1.5 h-1.5 rounded-full bg-rose-400" />
                    -3.35%
                  </p>
                </div>
              </div>
            </div>
          </div>

          {/* Your rooms section */}
          <div>
            <div className="flex items-center justify-between mb-4">
              <h2 className="text-lg font-semibold text-gray-800">
                Your Rooms {rooms.length}
              </h2>
            </div>

            {rooms.length === 0 ? (
              <div className="flex flex-col items-center justify-center py-12">
                <p className="text-gray-500 mb-1">No rooms found</p>
                <p className="text-sm text-gray-400">
                  Add rooms first to see per-room statistics.
                </p>
              </div>
            ) : (
              <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
                {rooms.map((room) => (
                  <div
                    key={room.id}
                    className="bg-white rounded-2xl shadow-sm border border-gray-200 overflow-hidden"
                  >
                    <div className="h-32 bg-gray-100">
                      <img
                        src={room.image || "/image-home-new.png"}
                        alt={room.name}
                        className="w-full h-full object-cover"
                        onError={(e) => {
                          (e.target as HTMLImageElement).src =
                            "/image-home-new.png";
                        }}
                      />
                    </div>
                    <div className="p-4">
                      <p className="text-sm text-gray-500 mb-1">
                        {room.deviceCount ?? 0} devices
                      </p>
                      <h3 className="text-base font-semibold text-gray-800 mb-1">
                        {room.name}
                      </h3>
                      <p className="text-xs text-gray-500">
                        20 kW {/* mock per-room usage */}
                      </p>
                    </div>
                  </div>
                ))}
              </div>
            )}
          </div>
        </div>
      </div>
    </div>
  );
}

