# PennDOT-Crash-Data-Spa
get that PennDOT data massaged for the GIS db

## pa_lat_long_crash.sql
This sql converts the latitude and longitude field in the PennDOT crash data (which is formatted as degrees, minutes, seconds) and converts these into decimal degrees.  Using the supplied decimal degrees formatted fields in the original data as geometry results in misplaced locations.

## pa_crash_cpa_codes.sql
This sql supplies the Philadelphia Planning Area codes to Philadelphia coded crash locations.  All Philly crashes are given a CPA code based on their location within a CPA polygon.  Philadelphia coded crashes that don't intersect a CPA polygon are given their closest CPA within 1600 meters.
