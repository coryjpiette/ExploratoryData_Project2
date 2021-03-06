# Baltimore City has seen a negative 8% compound annual growth rate from 1999-2008
# Los Angeles has experienced a positive 0.5% compound annual growth rate from 1999-2008 


scc.vehicles <- SCC[grep("Mobile.*Vehicles", SCC$EI.Sector),  ]; # Pattern match mobile vehicles in SCC description
scc.vehicles.list <- unique(scc.vehicles$SCC); # Create motor vehicle lookup list by SCC
nei.vehicles <- subset(NEI, SCC %in% scc.vehicles.list); # Filter for motor vehicle sources
nei.vehicles <- nei.vehicles %>% filter(fips == "24510"| fips == "06037"); # Filter for Baltimore City or Los Angeles County
nei.vehicles$fips[nei.vehicles$fips == "24510"] <- "Baltimore";
nei.vehicles$fips[nei.vehicles$fips == "06037"] <- "Los Angeles";
nei.vehicles <- merge(x = nei.vehicles, y = scc.vehicles[, c("SCC", "SCC.Level.Two")], by = "SCC"); # Join in descriptive data on SCC codes
nei.vehicles <- nei.vehicles %>% group_by(fips, year, SCC.Level.Two) %>% summarize(Annual.Total = sum(Emissions));
nei.vehicles.total <- nei.vehicles %>% group_by(fips, year) %>% summarize(Annual.Total = sum(Annual.Total)) %>% mutate(SCC.Level.Two = "Total");
nei.vehicles <- bind_rows(nei.vehicles, nei.vehicles.total);
nei.vehicles$SCC.Level.Two <- factor(nei.vehicles$SCC.Level.Two, levels = c("Total", "Highway Vehicles - Diesel", "Highway Vehicles - Gasoline"));
ggplot(nei.vehicles, aes(x = factor(year), y = Annual.Total, fill = SCC.Level.Two)) +
  geom_bar(stat = "identity") +
  facet_grid(fips ~ SCC.Level.Two) + 
  xlab("Year") +
  ylab(expression("Total Tons of PM"[2.5]*" Emissions")) + 
  ggtitle(expression(atop("Total Tons of PM"[2.5]*" Emissions from Motor Vehicle Sources", paste("in Baltimore City, MD and Los Angeles County, CA")))) +
  theme(plot.title = element_text(hjust = 0.5)) + # Center the plot title
  theme(plot.margin = unit(c(1,1,1,1), "cm")) + # Adjust plot margins
  scale_fill_brewer(palette = "Set1") +
  guides(fill = FALSE)
