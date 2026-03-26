import 'route_model.dart';

class BambalapitiyaData {
  static final List<RouteSchedule> allRoutes = [
    // ==========================================
    // RECYCLABLES (Trucks 1 & 2)
    // ==========================================
    RouteSchedule(
      wasteType: "Recyclables",
      truckId: "Truck 1",
      sector: "Sector A",
      days: "Tue & Fri",
      workload: "Large",
      lanes: [
        "5th Lane", "6th Lane", "8th Lane", "9th Lane", "10th Lane", 
        "12th Lane", "27th Lane", "28th Lane", '28th "A" Lane', "33rd Lane", 
        "34th Lane", "37th Lane", "Abdul Gaffoor Mawatha", "Alfred House Avenue", 
        "Alfred House Garden", "Alfred House Road", "Alfred Place", "Aloe Avenue"
      ],
    ),
    RouteSchedule(
      wasteType: "Recyclables",
      truckId: "Truck 1",
      sector: "Sector B",
      days: "Wed & Sat",
      workload: "Medium",
      lanes: [
        "Arthur Place", "Bagathale Road", "Charls Avenue", "Charls Circle", 
        "Charls Way", "Chelsea Garden", "Col. Jayawardane Mw.", "Deal Place", 
        'Deal Place "A"', "Deanston Place"
      ],
    ),
    RouteSchedule(
      wasteType: "Recyclables",
      truckId: "Truck 1",
      sector: "Sector C",
      days: "Sunday",
      workload: "Small",
      lanes: ['Deanston Place "A"', "Edward Lane", "Flower Road", "Flower Terrece"],
    ),
    RouteSchedule(
      wasteType: "Recyclables",
      truckId: "Truck 2",
      sector: "Sector D",
      days: "Tue & Fri",
      workload: "Small",
      lanes: ["Galle Road", "Glen Aber Place", "Inner Bagathale Road", "Inner Flower Road", "Lower Bagathale Road"],
    ),
    RouteSchedule(
      wasteType: "Recyclables",
      truckId: "Truck 2",
      sector: "Sector E",
      days: "Wed & Sat",
      workload: "Medium",
      lanes: [
        "Marine Drive", "Mile Post Avenue", "Nimalka Garden", "Palmayrah Avenue", 
        "Pediris Road", "Pentive Garden", "Queens Road", "R.A. De Mel Mawatha", 
        "Rehinland Place", "Schofild Place", "School Lane", "Sea Avenue"
      ],
    ),
    RouteSchedule(
      wasteType: "Recyclables",
      truckId: "Truck 2",
      sector: "Sector C", // Kept as Sector C per your prompt instruction
      days: "Sunday",
      workload: "Small (Rest of Lanes)",
      lanes: [
        "Siman Hewawitharana", "Sirikotha Avenue", "St. Anthony's Mawatha", 
        "Stambol Place", "Tea Boad Lane", "Temple Lane", "Thurstan Road", 
        "Unity Place", "Walukarama Road", "Waly Road"
      ],
    ),

    // ==========================================
    // NON-RECYCLABLES (Trucks 1 & 2)
    // ==========================================
    RouteSchedule(
      wasteType: "Non-Recyclables",
      truckId: "Truck 1",
      sector: "Sector A",
      days: "Monday",
      workload: "Large",
      lanes: [
        "5th Lane", "6th Lane", "8th Lane", "9th Lane", "10th Lane", 
        "12th Lane", "27th Lane", "28th Lane", '28th "A" Lane', "33rd Lane", 
        "34th Lane", "37th Lane", "Abdul Gaffoor Mawatha", "Alfred House Avenue", 
        "Alfred House Garden", "Alfred House Road", "Alfred Place", "Aloe Avenue",
        "Arthur Place", "Bagathale Road"
      ],
    ),
    RouteSchedule(
      wasteType: "Non-Recyclables",
      truckId: "Truck 1",
      sector: "Sector B",
      days: "Sunday",
      workload: "Small",
      lanes: [
        "Charls Avenue", "Charls Circle", "Charls Way", "Chelsea Garden", 
        "Col. Jayawardane Mw.", "Deal Place", 'Deal Place "A"', "Deanston Place", 
        'Deanston Place "A"'
      ],
    ),
    RouteSchedule(
      wasteType: "Non-Recyclables",
      truckId: "Truck 2",
      sector: "Sector C",
      days: "Monday",
      workload: "Large",
      lanes: [
        "Edward Lane", "Flower Road", "Flower Terrece", "Galle Road", 
        "Glen Aber Place", "Inner Bagathale Road", "Inner Flower Road", 
        "Lower Bagathale Road", "Marine Drive", "Mile Post Avenue", "Nimalka Garden", 
        "Palmayrah Avenue", "Pediris Road", "Pentive Garden", "Queens Road", 
        "R.A. De Mel Mawatha", "Rehinland Place", "Schofild Place", "School Lane", "Sea Avenue"
      ],
    ),
    RouteSchedule(
      wasteType: "Non-Recyclables",
      truckId: "Truck 2",
      sector: "Sector D",
      days: "Sunday",
      workload: "Small",
      lanes: [
        "Siman Hewawitharana", "Sirikotha Avenue", "St. Anthony's Mawatha", 
        "Stambol Place", "Tea Boad Lane", "Temple Lane", "Thurstan Road", 
        "Unity Place", "Walukarama Road", "Waly Road"
      ],
    ),

    // ==========================================
    // ORGANIC WASTE (Trucks 3 & 4)
    // ==========================================
    RouteSchedule(
      wasteType: "Organic",
      truckId: "Truck 3",
      sector: "Sector A",
      days: "Thursday",
      workload: "Large",
      lanes: [
        "5th Lane", "6th Lane", "8th Lane", "9th Lane", "10th Lane", 
        "12th Lane", "27th Lane", "28th Lane", '28th "A" Lane', "33rd Lane", 
        "34th Lane", "37th Lane", "Abdul Gaffoor Mawatha", "Alfred House Avenue", 
        "Alfred House Garden", "Alfred House Road", "Alfred Place", "Aloe Avenue",
        "Arthur Place", "Bagathale Road"
      ],
    ),
    RouteSchedule(
      wasteType: "Organic",
      truckId: "Truck 3",
      sector: "Sector B",
      days: "Sunday",
      workload: "Small",
      lanes: [
        "Charls Avenue", "Charls Circle", "Charls Way", "Chelsea Garden", 
        "Col. Jayawardane Mw.", "Deal Place", 'Deal Place "A"', "Deanston Place", 
        'Deanston Place "A"'
      ],
    ),
    RouteSchedule(
      wasteType: "Organic",
      truckId: "Truck 4", // Assuming Truck 4 based on your pattern
      sector: "Sector C",
      days: "Thursday",
      workload: "Large",
      lanes: [
        "Edward Lane", "Flower Road", "Flower Terrece", "Galle Road", 
        "Glen Aber Place", "Inner Bagathale Road", "Inner Flower Road", 
        "Lower Bagathale Road", "Marine Drive", "Mile Post Avenue", "Nimalka Garden", 
        "Palmayrah Avenue", "Pediris Road", "Pentive Garden", "Queens Road", 
        "R.A. De Mel Mawatha", "Rehinland Place", "Schofild Place", "School Lane", "Sea Avenue"
      ],
    ),
    RouteSchedule(
      wasteType: "Organic",
      truckId: "Truck 4", // Corrected from your prompt's "Truck 2" typo
      sector: "Sector D",
      days: "Sunday",
      workload: "Small",
      lanes: [
        "Siman Hewawitharana", "Sirikotha Avenue", "St. Anthony's Mawatha", 
        "Stambol Place", "Tea Boad Lane", "Temple Lane", "Thurstan Road", 
        "Unity Place", "Walukarama Road", "Waly Road"
      ],
    ),
  ];
}