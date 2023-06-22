public class GoogleMapJSONUtil {

        public class Address_components {
            public String long_name;
            public String short_name;
            public List<String> types;
        }

        public class Geometry {
            public Bounds bounds;
            public Northeast location;
            public String location_type;
            public Bounds viewport;
        }

        public class GoogleMapJSON {
            public List<Results> results;
            public String status;
            public String error_message;
        }

        public class Results {
            public List<Address_components> address_components;
            public String formatted_address;
            public Geometry geometry;
            public String place_id;
            public List<String> types;
        }

        public class Bounds {
            public Northeast northeast;
            public Northeast southwest;
        }

        public class Northeast {
            public Double lat;
            public Double lng;
        }

        
        public static GoogleMapJSON parse(String json) {
            return (GoogleMapJSON) System.JSON.deserialize(json, GoogleMapJSON.class);
        }
}