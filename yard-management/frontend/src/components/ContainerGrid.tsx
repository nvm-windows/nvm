import { useRef, useEffect } from "react";
import { getContainersForBayLevel } from "@/lib/containerData";
import type { Container } from "@shared/schema";
import { Package } from "lucide-react";

interface ContainerGridProps {
  bay: string;
  level: string;
  highlightedContainerId: string | null;
}

export function ContainerGrid({ bay, level, highlightedContainerId }: ContainerGridProps) {
  const containers = getContainersForBayLevel(bay, level);
  const gridRef = useRef<HTMLDivElement>(null);
  const highlightedRef = useRef<HTMLDivElement>(null);

  // Create a map for quick lookup of containers by position
  const containerMap = new Map<string, Container>();
  containers.forEach((c) => {
    containerMap.set(`${c.row}-${c.column}`, c);
  });

  // Scroll to highlighted container
  useEffect(() => {
    if (highlightedContainerId && highlightedRef.current) {
      highlightedRef.current.scrollIntoView({
        behavior: "smooth",
        block: "center",
        inline: "center",
      });
    }
  }, [highlightedContainerId]);

  const rows = Array.from({ length: 12 }, (_, i) => i + 1);
  const columns = Array.from({ length: 5 }, (_, i) => i + 1);

  return (
    <div className="flex-1 overflow-hidden flex flex-col">
      <div 
        ref={gridRef} 
        className="flex-1 overflow-auto custom-scrollbar relative"
      >
        <div className="min-w-max">
          {/* Header Row - Column Numbers (sticky top) */}
          <div className="flex sticky top-0 z-20 bg-background">
            {/* Corner cell - sticky both ways */}
            <div className="w-14 flex-shrink-0 sticky left-0 z-30 bg-background p-1">
              <div className="h-10 bg-muted rounded-md" />
            </div>
            {columns.map((col) => (
              <div
                key={col}
                className="w-36 flex-shrink-0 p-1"
                data-testid={`header-col-${col}`}
              >
                <div className="h-10 flex items-center justify-center bg-accent/40 rounded-md font-semibold text-sm">
                  {col}
                </div>
              </div>
            ))}
          </div>

          {/* Grid Rows */}
          {rows.map((row) => (
            <div key={row} className="flex">
              {/* Row Header - sticky left */}
              <div
                className="w-14 flex-shrink-0 p-1 sticky left-0 z-10 bg-background"
                data-testid={`header-row-${row}`}
              >
                <div className="h-20 flex items-center justify-center bg-primary/10 rounded-md font-semibold text-primary">
                  {row}
                </div>
              </div>
              
              {/* Container Cells */}
              {columns.map((col) => {
                const container = containerMap.get(`${row}-${col}`);
                const isHighlighted = container?.id === highlightedContainerId;
                
                return (
                  <div
                    key={`${row}-${col}`}
                    className="w-36 flex-shrink-0 p-1"
                  >
                    <div
                      ref={isHighlighted ? highlightedRef : null}
                      className={`h-20 rounded-md border-2 border-dashed transition-all duration-200 flex flex-col items-center justify-center p-2 ${
                        isHighlighted
                          ? "bg-destructive text-destructive-foreground border-destructive"
                          : container
                          ? "bg-primary/5 border-primary/30 hover:bg-primary/10 hover:border-primary/50"
                          : "bg-muted/30 border-muted-foreground/20"
                      }`}
                      data-testid={`cell-${row}-${col}`}
                    >
                      {container ? (
                        <>
                          <span 
                            className={`font-mono text-xs font-bold ${isHighlighted ? "" : "text-foreground"}`}
                            data-testid={`container-no-${container.id}`}
                          >
                            {container.containerNo}
                          </span>
                          <span 
                            className={`text-xs mt-1 ${isHighlighted ? "text-destructive-foreground/80" : "text-muted-foreground"}`}
                            data-testid={`container-type-${container.id}`}
                          >
                            {container.type} - {container.size}
                          </span>
                        </>
                      ) : (
                        <Package className="w-5 h-5 text-muted-foreground/30" />
                      )}
                    </div>
                  </div>
                );
              })}
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}
