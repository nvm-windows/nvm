import { Button } from "@/components/ui/button";
import { ContainerSearch } from "./ContainerSearch";
import { ChevronLeft, ChevronRight, Container, LogOut } from "lucide-react";
import type { Container as ContainerType } from "@shared/schema";

interface DashboardHeaderProps {
  currentBay: string;
  currentLevel: string;
  onBayChange: (bay: string) => void;
  onLevelChange: (level: string) => void;
  onContainerSelect: (container: ContainerType, bay: string, level: string) => void;
  onSearchClear: () => void;
  onLogout: () => void;
}

const bays = ["A1", "A2", "A3", "A4", "A5"];
const levels = ["L1", "L2", "L3", "L4"];

export function DashboardHeader({
  currentBay,
  currentLevel,
  onBayChange,
  onLevelChange,
  onContainerSelect,
  onSearchClear,
  onLogout,
}: DashboardHeaderProps) {
  const currentBayIndex = bays.indexOf(currentBay);

  const handlePrevBay = () => {
    if (currentBayIndex > 0) {
      onBayChange(bays[currentBayIndex - 1]);
    }
  };

  const handleNextBay = () => {
    if (currentBayIndex < bays.length - 1) {
      onBayChange(bays[currentBayIndex + 1]);
    }
  };

  return (
    <header className="sticky top-0 z-20 bg-card border-b shadow-sm">
      <div className="flex items-center justify-between gap-4 p-4">
        {/* Bay Indicator with Navigation */}
        <div className="flex items-center gap-2">
          <Button
            size="icon"
            variant="ghost"
            onClick={handlePrevBay}
            disabled={currentBayIndex === 0}
            data-testid="button-prev-bay"
          >
            <ChevronLeft className="w-5 h-5" />
          </Button>
          
          <div 
            className="flex items-center gap-3 px-4 py-2 bg-gradient-to-r from-primary/10 to-primary/5 rounded-lg"
            data-testid="bay-indicator"
          >
            <Container className="w-6 h-6 text-primary" />
            <span className="text-2xl font-bold tracking-tight">BAY - {currentBay}</span>
          </div>
          
          <Button
            size="icon"
            variant="ghost"
            onClick={handleNextBay}
            disabled={currentBayIndex === bays.length - 1}
            data-testid="button-next-bay"
          >
            <ChevronRight className="w-5 h-5" />
          </Button>
        </div>

        {/* Level Selection */}
        <div className="flex items-center gap-1 bg-muted/50 p-1 rounded-lg">
          {levels.map((level) => (
            <Button
              key={level}
              size="sm"
              variant={currentLevel === level ? "default" : "ghost"}
              onClick={() => onLevelChange(level)}
              className={`min-w-12 font-semibold transition-all ${
                currentLevel === level 
                  ? "bg-accent text-accent-foreground shadow-sm" 
                  : ""
              }`}
              data-testid={`button-level-${level}`}
            >
              {level}
            </Button>
          ))}
        </div>

        {/* Search and Actions */}
        <div className="flex items-center gap-4">
          <ContainerSearch 
            onContainerSelect={onContainerSelect} 
            onClear={onSearchClear}
          />
          <Button
            size="icon"
            variant="ghost"
            onClick={onLogout}
            className="text-muted-foreground hover:text-destructive"
            data-testid="button-logout"
          >
            <LogOut className="w-5 h-5" />
          </Button>
        </div>
      </div>

      {/* Bay Tabs */}
      <div className="flex items-center gap-1 px-4 pb-3">
        {bays.map((bay) => (
          <Button
            key={bay}
            size="sm"
            variant={currentBay === bay ? "secondary" : "ghost"}
            onClick={() => onBayChange(bay)}
            className={`min-w-16 ${currentBay === bay ? "font-semibold" : ""}`}
            data-testid={`button-bay-${bay}`}
          >
            {bay}
          </Button>
        ))}
      </div>
    </header>
  );
}
