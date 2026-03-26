class RouteSchedule {
  final String wasteType; // "Recyclables", "Non-Recyclables", "Organic"
  final String truckId;   // e.g., "Truck 1"
  final String sector;    // e.g., "Sector A"
  final String days;      // e.g., "Tue & Fri"
  final String workload;  // "Large", "Medium", "Small"
  final List<String> lanes;

  RouteSchedule({
    required this.wasteType,
    required this.truckId,
    required this.sector,
    required this.days,
    required this.workload,
    required this.lanes,
  });
}