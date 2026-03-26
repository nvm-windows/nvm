import { useState } from "react";
import { DashboardHeader } from "./DashboardHeader";
import { ContainerGrid } from "./ContainerGrid";
import type { Container } from "@shared/schema";
import { Building2 } from "lucide-react";

interface DashboardProps {
  onLogout: () => void;
}

export function Dashboard({ onLogout }: DashboardProps) {
  const [currentBay, setCurrentBay] = useState("A1");
  const [currentLevel, setCurrentLevel] = useState("L1");
  const [highlightedContainerId, setHighlightedContainerId] = useState<string | null>(null);

  const handleContainerSelect = (container: Container, bay: string, level: string) => {
    setCurrentBay(bay);
    setCurrentLevel(level);
    setHighlightedContainerId(container.id);
  };

  const handleSearchClear = () => {
    setHighlightedContainerId(null);
  };

  return (
    <div className="min-h-screen flex flex-col bg-background">
      {/* Top Bar with Company Info */}
      <div className="bg-primary text-primary-foreground py-2 px-4">
        <div className="flex items-center justify-between">
          <div className="flex items-center gap-2">
            <Building2 className="w-5 h-5" />
            <span className="font-semibold">Indev Infra Private Ltd</span>
            <span className="text-primary-foreground/70 text-sm">| Mumbai</span>
          </div>
          <span className="text-sm text-primary-foreground/70">
            Container Location Update System
          </span>
        </div>
      </div>

      {/* Main Header with Navigation */}
      <DashboardHeader
        currentBay={currentBay}
        currentLevel={currentLevel}
        onBayChange={setCurrentBay}
        onLevelChange={setCurrentLevel}
        onContainerSelect={handleContainerSelect}
        onSearchClear={handleSearchClear}
        onLogout={onLogout}
      />

      {/* Grid Display Info Bar */}
      <div className="bg-muted/30 border-b px-4 py-2 flex items-center justify-between">
        <div className="flex items-center gap-4">
          <span className="text-sm font-medium">
            Viewing: <span className="text-primary">Bay {currentBay}</span> - <span className="text-accent-foreground bg-accent px-2 py-0.5 rounded text-xs font-semibold">{currentLevel}</span>
          </span>
          {highlightedContainerId && (
            <span className="text-xs bg-destructive/10 text-destructive px-2 py-1 rounded-full">
              Container highlighted
            </span>
          )}
        </div>
        <div className="flex items-center gap-2 text-sm text-muted-foreground">
          <div className="flex items-center gap-1">
            <div className="w-3 h-3 rounded border-2 border-dashed border-primary/30 bg-primary/5" />
            <span>Container</span>
          </div>
          <div className="flex items-center gap-1 ml-4">
            <div className="w-3 h-3 rounded border-2 border-dashed border-muted-foreground/20 bg-muted/30" />
            <span>Empty</span>
          </div>
          <div className="flex items-center gap-1 ml-4">
            <div className="w-3 h-3 rounded bg-destructive" />
            <span>Highlighted</span>
          </div>
        </div>
      </div>

      {/* Container Grid */}
      <ContainerGrid
        bay={currentBay}
        level={currentLevel}
        highlightedContainerId={highlightedContainerId}
      />

      {/* Footer */}
      <footer className="bg-card border-t py-2 px-4 text-center text-xs text-muted-foreground">
        Container Location Update System - Indev Infra Private Ltd, Mumbai
      </footer>
    </div>
  );
}
