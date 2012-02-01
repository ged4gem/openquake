/*
  Documentation for the OpenQuake database schema.
  Please keep these alphabetical by table.

    Copyright (c) 2010-2011, GEM Foundation.

    OpenQuake is free software: you can redistribute it and/or modify
    it under the terms of the GNU Lesser General Public License version 3
    only, as published by the Free Software Foundation.

    OpenQuake is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Lesser General Public License version 3 for more details
    (a copy is included in the LICENSE file that accompanied this code).

    You should have received a copy of the GNU Lesser General Public License
    version 3 along with OpenQuake.  If not, see
    <http://www.gnu.org/licenses/lgpl-3.0.txt> for a copy of the LGPLv3 License.
*/

COMMENT ON SCHEMA admin IS 'Administrative data';
COMMENT ON SCHEMA eqcat IS 'Earthquake catalog';
COMMENT ON SCHEMA eqged IS 'earthquake global exposure database';
COMMENT ON SCHEMA pshai IS 'PSHA input model';
COMMENT ON SCHEMA uiapi IS 'Data required by the API presented to the various OpenQuake UIs';

COMMENT ON TABLE admin.organization IS 'An organization that is utilising the OpenQuake database';
COMMENT ON TABLE admin.oq_user IS 'An OpenQuake user that is utilising the OpenQuake database';
COMMENT ON COLUMN admin.oq_user.data_is_open IS 'Whether the data owned by the user is visible to the general public.';
COMMENT ON TABLE admin.revision_info IS 'Facilitates the keeping of revision information for the OpenQuake database and/or its artefacts (schemas, tables etc.)';
COMMENT ON COLUMN admin.revision_info.artefact IS 'The name of the database artefact for which we wish to store revision information.';
COMMENT ON COLUMN admin.revision_info.revision IS 'The revision information for the associated database artefact.';
COMMENT ON COLUMN admin.revision_info.step IS 'A simple counter that will be used to facilitate schema upgrades and/or data migration.';
COMMENT ON COLUMN admin.revision_info.last_update IS 'The date/time when the revision information was last updated. Please note: this time stamp is not refreshed automatically. It is expected that schema/data migration scripts will modify this as appropriate.';

COMMENT ON TABLE eqcat.catalog IS 'Table with earthquake catalog data, the magnitude(s) and the event surface is kept in separate tables.';
COMMENT ON COLUMN eqcat.catalog.depth IS 'Earthquake depth (in km)';
COMMENT ON COLUMN eqcat.catalog.event_class IS 'Either unknown (NULL) or one of: ''aftershock'', ''foreshock''.';
COMMENT ON COLUMN eqcat.catalog.magnitude_id IS 'Foreign key to the row with the magnitude data.';
COMMENT ON COLUMN eqcat.catalog.surface_id IS 'Foreign key to the row with the earthquake surface data.';
COMMENT ON COLUMN eqcat.catalog.time IS 'Earthquake date and time';

COMMENT ON TABLE eqcat.magnitude IS 'Table with earthquake magnitudes in different units of measurement. At least one magnitude value must be set.';

COMMENT ON TABLE eqcat.surface IS 'Table with earthquake surface data, basically an ellipse and a strike angle.';
COMMENT ON COLUMN eqcat.surface.semi_minor IS 'Semi-minor axis: The shortest radius of an ellipse.';
COMMENT ON COLUMN eqcat.surface.semi_major IS 'Semi-major axis: The longest radius of an ellipse.';

COMMENT ON VIEW eqcat.catalog_allfields IS 'A global catalog view, needed for geonode integration';

COMMENT ON DOMAIN eqged.nonnegative IS 'Non-negative value (x >= 0, x numeric)';

COMMENT ON DOMAIN eqged.proportion IS 'Proportion (0 <= x <= 1, x double)';

COMMENT ON DOMAIN eqged.taxonomy IS 'Taxonomy type (currently only PAGER is supported)';

COMMENT ON TABLE eqged.admin_3 IS 'Borders layer the third administrative level. Useful for matching admin-level attributes to the grid_point table. Also may be used for cartographic purposes.';
COMMENT ON COLUMN eqged.admin_3.id IS 'Unique identifier';
COMMENT ON COLUMN eqged.admin_3.name IS 'Region name in English';
COMMENT ON COLUMN eqged.admin_3.varname IS 'Alternate region name, often in local language';
COMMENT ON COLUMN eqged.admin_3.the_geom IS 'Polygon representing a regional boundary.'; 
COMMENT ON COLUMN eqged.admin_3.shape_perimeter IS 'Length of the polygon perimeter in km';
COMMENT ON COLUMN eqged.admin_3.shape_area IS 'Area of the polygon in square km';
COMMENT ON COLUMN eqged.admin_3.gadm_admin_2_id IS 'Parent second level GADM administrative region identifier'
COMMENT ON COLUMN eqged.gadm_admin_1.date IS 'Date of update for the country';

COMMENT ON TABLE eqged.agg_build_infra IS 'result of mapping scheme assignment for grid_point. each grid_point can have multiple records here';
COMMENT ON TABLE eqged.agg_build_infra.id IS 'Unique identifier';
COMMENT ON TABLE eqged.agg_build_infra.agg_build_infra_src_id IS 'Aggregate building infrastructure source identifier';
COMMENT ON TABLE eqged.agg_build_infra.mapping_scheme_id IS 'Mapping scheme identifier';
COMMENT ON TABLE eqged.agg_build_infra.compound_ms_value IS 'Compound mapping scheme ratio';
COMMENT ON TABLE eqged.agg_build_infra.study_region_id IS 'study region identifier (TODO could be redundant)';

COMMENT ON TABLE eqged.agg_build_infra_pop IS 'aggregate building infrastructure population values';
COMMENT ON COLUMN eqged.agg_build_infra_pop.id IS 'Unique identifier'
COMMENT ON COLUMN eqged.agg_build_infra_pop.agg_build_infra_pop_ratio_id IS ''
COMMENT ON COLUMN eqged.agg_build_infra_pop.population_id IS 'population identifier';
COMMENT ON COLUMN eqged.agg_build_infra_pop.day_pop IS 'day time population at the grid';
COMMENT ON COLUMN eqged.agg_build_infra_pop.night_pop IS 'night time population at the grid';
COMMENT ON COLUMN eqged.agg_build_infra_pop.transit_pop IS 'transit time population at the grid';
COMMENT ON COLUMN eqged.agg_build_infra_pop.num_buildings IS 'number of buildings for matching classification';
COMMENT ON COLUMN eqged.agg_build_infra_pop.struct_area IS 'Total structure area';
COMMENT ON COLUMN eqged.agg_build_infra_pop.study_region_id IS 'study region identifier (TODO field could be redundant)';

COMMENT ON TABLE eqged.agg_build_infra_pop_ratio IS 'aggregate building infrastructure population ratios';
COMMENT ON COLUMN eqged.agg_build_infra_pop_ratio.id IS 'Unique identifier'
COMMENT ON COLUMN eqged.agg_build_infra_pop_ratio.gadm_country_id IS 'GADM country identifier';
COMMENT ON COLUMN eqged.agg_build_infra_pop_ratio.grid_point_id IS 'grid point identifier';
COMMENT ON COLUMN eqged.agg_build_infra_pop_ratio.agg_build_infra_id IS 'Aggregate building infrastructure identifier';
COMMENT ON COLUMN eqged.agg_build_infra_pop_ratio.day_pop_ratio IS 'compound ratio for day time population at the grid';
COMMENT ON COLUMN eqged.agg_build_infra_pop_ratio.night_pop_ratio IS 'compound ratio for night time population at the grid';
COMMENT ON COLUMN eqged.agg_build_infra_pop_ratio.transit_pop_ratio IS 'compound ratio for transit time population at the grid';
COMMENT ON COLUMN eqged.agg_build_infra_pop_ratio.study_region_id IS 'study region identifier (TODO field could be redundant)';
COMMENT ON COLUMN eqged.agg_build_infra_pop_ratio.occupancy IS 'grid point occupancy class (TODO convert to id, possibly remove field altogether)';

COMMENT ON TABLE eqged.agg_build_infra_src IS 'metadata describing how the numbers in agg_build_infra were calculated. Either the_geom, or one of gadm_*_id must be set. If the_geom is set, source will match arbitrary geometry. If gadm_*_id is set, source will match the most specific GADM region.';
COMMENT ON COLUMN eqged.agg_build_infra_src.id IS 'Unique identifier';
COMMENT ON COLUMN eqged.agg_build_infra_src.the_geom IS 'Geometry of area within the study region to which the selected mapping scheme is applied.';
COMMENT ON COLUMN eqged.agg_build_infra_src.shape_perimeter IS 'perimeter of geometry, to keep consistency with ESRI format';
COMMENT ON COLUMN eqged.agg_build_infra_src.shape_area IS 'area of geometry, to keep consistency with ESRI format';
COMMENT ON COLUMN eqged.agg_build_infra_src.date IS 'Source creation date';
COMMENT ON COLUMN eqged.agg_build_infra_src.notes IS 'Usage notes';
COMMENT ON COLUMN eqged.agg_build_infra_src.mapping_scheme_src_id IS 'Mapping scheme source identifier';
COMMENT ON COLUMN eqged.agg_build_infra_src.study_region_id IS 'Study region identifier';
COMMENT ON COLUMN eqged.agg_build_infra_src.gadm_country_id IS 'GADM country identifier this source refers to.';
COMMENT ON COLUMN eqged.agg_build_infra_src.gadm_admin_1_id IS 'GADM first level administrative region identifier this source refers to.';
COMMENT ON COLUMN eqged.agg_build_infra_src.gadm_admin_2_id IS 'GADM second level administrative region identifier this source refers to.';

COMMENT ON TABLE eqged.cresta_country IS 'Catastrophe Risk Evaluating and Standardizing Target Accumulations (CRESTA) layer at the country level. TODO somehow acquire geometries for this and add them.';
COMMENT ON COLUMN eqged.cresta_country.gadm_country_id IS 'Equivalent GADM country identifier';
COMMENT ON COLUMN eqged.cresta_country.name IS 'CRESTA country name';
COMMENT ON COLUMN eqged.cresta_country.zone_count IS 'Number of zones contained in the country';
COMMENT ON COLUMN eqged.cresta_country.zone_count IS 'Total number of subzones contained in the country';

COMMENT ON TABLE eqged.cresta_zone IS 'Catastrophe Risk Evaluating and Standardizing Target Accumulations (CRESTA) layer at the sub-country level (first and second admininistrative). TODO somehow acquire geometries for this and add them.';
COMMENT ON COLUMN eqged.cresta_country.id IS 'Unique identifier';
COMMENT ON COLUMN eqged.cresta_country.gadm_country_id IS 'Parent GADM country identifier';
COMMENT ON COLUMN eqged.cresta_country.cresta_id IS 'CRESTA zone identifier';
COMMENT ON COLUMN eqged.cresta_country.zone_name IS 'CRESTA zone name';
COMMENT ON COLUMN eqged.cresta_country.zone_number IS 'CRESTA zone number';
COMMENT ON COLUMN eqged.cresta_country.is_subzone IS 'Zone level flag (zone is first level, subzone is second level)';

COMMENT ON TABLE eqged.gadm_admin_1 IS 'Global Administrative Units layer at the first administrative level. Useful for matching admin-level attributes to the grid_point table. Also may be used for cartographic purposes.';
COMMENT ON COLUMN eqged.gadm_admin_1.id IS 'Unique identifier';
COMMENT ON COLUMN eqged.gadm_admin_1.name IS 'Region name in English';
COMMENT ON COLUMN eqged.gadm_admin_1.varname IS 'Alternate region name, often in local language';
COMMENT ON COLUMN eqged.gadm_admin_1.iso IS '3-letter International Organization for Standardization (ISO) code. Useful for joining with country-level attributes.';
COMMENT ON COLUMN eqged.gadm_admin_1.type IS 'Name of the region type 
(e.g. state, region, etc.) in local language';
COMMENT ON COLUMN eqged.gadm_admin_1.engtype IS 'Name of the region type 
(e.g. state, region, etc.) in English';
COMMENT ON COLUMN eqged.gadm_admin_1.the_geom IS 'Polygon representing a regional boundary.'; 
COMMENT ON COLUMN eqged.gadm_admin_1.shape_perimeter IS 'Length of the polygon perimeter in km';
COMMENT ON COLUMN eqged.gadm_admin_1.shape_area IS 'Area of the polygon in square km';
COMMENT ON COLUMN eqged.gadm_admin_1.gadm_country_id IS 'Parent GADM country identifier'
COMMENT ON COLUMN eqged.gadm_admin_1.date IS 'Date of update for the country';

COMMENT ON TABLE eqged.gadm_admin_2 IS 'Global Administrative Units layer at the second administrative level. Useful for matching admin-level attributes to the grid_point table. Also may be used for cartographic purposes.';
COMMENT ON COLUMN eqged.gadm_admin_2.id IS 'Unique identifier';
COMMENT ON COLUMN eqged.gadm_admin_2.name IS 'Region name in English';
COMMENT ON COLUMN eqged.gadm_admin_2.varname IS 'Alternate region name, often in local language';
COMMENT ON COLUMN eqged.gadm_admin_2.iso IS '3-letter International Organization for Standardization (ISO) code. Useful for joining with country-level attributes.';
COMMENT ON COLUMN eqged.gadm_admin_2.type IS 'Name of the region type 
(e.g. state, region, etc.) in local language';
COMMENT ON COLUMN eqged.gadm_admin_2.engtype IS 'Name of the region type 
(e.g. state, region, etc.) in English';
COMMENT ON COLUMN eqged.gadm_admin_2.the_geom IS 'Polygon representing a regional boundary.'; 
COMMENT ON COLUMN eqged.gadm_admin_2.shape_perimeter IS 'Length of the polygon perimeter in km';
COMMENT ON COLUMN eqged.gadm_admin_2.shape_area IS 'Area of the polygon in square km';
COMMENT ON COLUMN eqged.gadm_admin_2.gadm_admin_1_id IS 'Parent GADM fist administrative region identifier'
COMMENT ON COLUMN eqged.gadm_admin_2.date IS 'Date of update for the country';

COMMENT ON TABLE eqged.gadm_country IS 'Global Administrative Units layer at the country level. Useful for matching country-level attributes to the grid_point table. Also may be used for cartographic purposes.';
COMMENT ON COLUMN eqged.gadm_country.id IS 'Unique identifier';
COMMENT ON COLUMN eqged.gadm_country.name IS 'Country name in English';
COMMENT ON COLUMN eqged.gadm_country.alias IS 'Alternate country name, often in local language';
COMMENT ON COLUMN eqged.gadm_country.iso IS '3-letter International Organization for Standardization (ISO) code. Useful for joining with country-level attributes.';
COMMENT ON COLUMN eqged.gadm_country.the_geom IS 'Polygon representing a country boundary. Note that some "countries" are actually regions or territories, such as Puerto Rico, which has it''s own polygon and ISO code despite being a U.S. Commonwealth.';
COMMENT ON COLUMN eqged.gadm_country.simple_geom IS 'Simplified version of the_geom for visualization purposes.'; 
COMMENT ON COLUMN eqged.gadm_country.shape_perimeter IS 'Length of the polygon perimeter in km';
COMMENT ON COLUMN eqged.gadm_country.shape_area IS 'Area of the polygon in square km';
COMMENT ON COLUMN eqged.gadm_country.date IS 'Date of update for the country';

COMMENT ON TABLE eqged.gadm_country_attribute IS 'Extra attributes for GADM country level layer.'
COMMENT ON COLUMN eqged.gadm_country_attribute.id IS 'Unique identifier';
COMMENT ON COLUMN eqged.gadm_country_attribute.gadm_country_id IS 'GADM country identifier';
COMMENT ON COLUMN eqged.gadm_country_attribute.people_dwelling IS 'mean number of people per dwelling';
COMMENT ON COLUMN eqged.gadm_country_attribute.people_dwelling_source IS 'Source used for the people_dwelling data';
COMMENT ON COLUMN eqged.gadm_country_attribute.people_dwelling_date IS 'Date of the people_dwelling data';
COMMENT ON COLUMN eqged.gadm_country_attribute.dwellings_building IS 'mean number of dwellings per building';
COMMENT ON COLUMN eqged.gadm_country_attribute.dwellings_building_source IS 'Source used for the dwellings_building data';
COMMENT ON COLUMN eqged.gadm_country_attribute.dwellings_building_date IS 'Date of the dwellings_building data';
COMMENT ON COLUMN eqged.gadm_country_attribute.people_building IS 'mean number of people per building';
COMMENT ON COLUMN eqged.gadm_country_attribute.people_building_source IS 'Source used for the people_building data';
COMMENT ON COLUMN eqged.gadm_country_attribute.people_building_date IS 'Date of the people_building data';
COMMENT ON COLUMN eqged.gadm_country_attribute.building_area IS 'mean building area';
COMMENT ON COLUMN eqged.gadm_country_attribute.building_area_source IS 'Source used for the building_area data';
COMMENT ON COLUMN eqged.gadm_country_attribute.building_area_date IS 'Date of the building_area data';
COMMENT ON COLUMN eqged.gadm_country_attribute.replacement_cost IS 'replacement cost per m^2';
COMMENT ON COLUMN eqged.gadm_country_attribute.replacement_cost_source IS 'Source used for the replacement_cost data';
COMMENT ON COLUMN eqged.gadm_country_attribute.replacement_cost_date IS 'Date of the replacement_cost data';
COMMENT ON COLUMN eqged.gadm_country_attribute.num_buildings IS 'mean number of buildings';
COMMENT ON COLUMN eqged.gadm_country_attribute.num_buildings_source IS 'Source used for the num_buildings data';
COMMENT ON COLUMN eqged.gadm_country_attribute.num_buildings_date IS 'Date of the num_buildings data';
COMMENT ON COLUMN eqged.gadm_country_attribute.labour_cost IS 'mean hourly compensation for labour';
COMMENT ON COLUMN eqged.gadm_country_attribute.labour_cost_source IS 'Source used for the labour_cost data';
COMMENT ON COLUMN eqged.gadm_country_attribute.labour_cost_date IS 'Date of the labour_cost data';
COMMENT ON COLUMN eqged.gadm_country_attribute.gdp IS 'Gross domestic product of the country';
COMMENT ON COLUMN eqged.gadm_country_attribute.gdp_source IS 'Source used for the gdp data';
COMMENT ON COLUMN eqged.gadm_country_attribute.gdp_date IS 'Date of the gdp data';

COMMENT ON TABLE eqged.gadm_country_facts IS 'GADM country facts (flat table for visualization).';

COMMENT ON TABLE eqged.gadm_country_population IS 'Population values aggregated by GADM country region. Can be rebuilt using function eqged.rebuild_gadm_country_population().';
COMMENT ON COLUMN eqged.gadm_country_population.id IS 'Unique identifier';
COMMENT ON COLUMN eqged.gadm_country_population.gadm_country_id IS 'GADM country identifier';
COMMENT ON COLUMN eqged.gadm_country_population.population_src_id IS 'Population source identifier';
COMMENT ON COLUMN eqged.gadm_country_population.pop_value IS 'Aggregate population value (total number of people) for the given GADM country';
COMMENT ON COLUMN eqged.gadm_country_population.pop_count IS 'Number of populated grid cells in the given GADM country';

COMMENT ON TABLE eqged.gem_exposure IS 'GEM exposure (flat table for visualization).';

COMMENT ON TABLE eqged.grid_point IS 'Table to store the geometry of points representing 30 arc-second cells. Mapping schemes are applied to these cells to produce global or regional sets of data with modeled or measured exposure attributes for use in GEM software.';
COMMENT ON COLUMN eqged.grid_point.id IS 'Unique identifier';
COMMENT ON COLUMN eqged.grid_point.the_geom IS 'Point geometry, one point for every 30 arc-second cell of the planet''s inhabitable land area (excludes Antarctica, water bodies, permanent ice, and oceans). Can easily be converted to a raster. Point-in-polygon operation (via SQL or programmatically) can be used to identify points within a mapping scheme geometry.';
COMMENT ON COLUMN eqged.grid_point.lat IS 'Latitude of the point in decimal degrees. Although available from the_geom, it is also easier to store than calculate on the fly. Additionally, if the point data are projected this is not readily available.';
COMMENT ON COLUMN eqged.grid_point.lon IS 'Longitude of the point in decimal degrees. Although available from the_geom, it is also easier to store than calculate on the fly. Additionally, if the point data are projected this is not readily available.';

COMMENT ON TABLE eqged.grid_point_admin_1 IS 'Link between gadm_admin_1 table and grid_point table, precalculates the spatial relationship (point-in-polygon) to save on computation time. Can be rebuilt using function eqged.rebuild_grid_point_admin_1().';
COMMENT ON COLUMN eqged.grid_point_country.gadm_admin_1_id IS 'Foreign key linked to gadm_admin_1';
COMMENT ON COLUMN eqged.grid_point_country.grid_point_id IS 'Foreign key linked to grid_point';

COMMENT ON TABLE eqged.grid_point_admin_2 IS 'Link between gadm_admin_2 table and grid_point table, precalculates the spatial relationship (point-in-polygon) to save on computation time. Can be rebuilt using function eqged.rebuild_grid_point_admin_2().';
COMMENT ON COLUMN eqged.grid_point_country.gadm_admin_2_id IS 'Foreign key linked to gadm_admin_2';
COMMENT ON COLUMN eqged.grid_point_country.grid_point_id IS 'Foreign key linked to grid_point';

COMMENT ON TABLE eqged.grid_point_admin_3 IS 'Link between admin_3 table and grid_point table, precalculates the spatial relationship (point-in-polygon) to save on computation time.';
COMMENT ON COLUMN eqged.grid_point_country.admin_3_id IS 'Foreign key linked to admin_3';
COMMENT ON COLUMN eqged.grid_point_country.grid_point_id IS 'Foreign key linked to grid_point';

COMMENT ON TABLE eqged.grid_point_attribute IS 'Simple attributes of the grid points. Kept in a separate table to ease database loading.';
COMMENT ON COLUMN eqged.grid_point_attribute.grid_point_id IS 'Grid point identifier';
COMMENT ON COLUMN eqged.grid_point_attribute.land_area IS 'Land area in square km of the 30 arc-second cell. Useful for calculating densities (population, housing, etc.). Varies with latitude. For cells that are part land and part water or permanent ice, the area only reflects the land portion of the cell.';
COMMENT ON COLUMN eqged.grid_point_attribute.is_urban IS 'Boolean flag for geometries that are within an urban area as defined by the GRUMPv1 urban-rural layer.';
COMMENT ON COLUMN eqged.grid_point_attribute.urban_measure_quality IS 'Qualitative measure of the reliability of the urban-rural mask on a per-point basis. Not yet available.';
COMMENT ON COLUMN eqged.grid_point_attribute.date_created IS 'Date of last update for the point.';
COMMENT ON COLUMN eqged.grid_point_attribute.cresta_zone IS 'Cresta zone identifier (foreign key)';
COMMENT ON COLUMN eqged.grid_point_attribute.cresta_subzone IS 'Cresta subzone identifier (foreign key)';
COMMENT ON COLUMN eqged.grid_point_attribute.organization_id IS 'organization identifier (foreign key)';

COMMENT ON TABLE eqged.grid_point_country IS 'Link between gadm_country table and grid_point table, precalculates the spatial relationship (point-in-polygon) to save on computation time. Can be rebuilt using function eqged.rebuild_grid_point_country().';
COMMENT ON COLUMN eqged.grid_point_country.gadm_country_id IS 'Foreign key linked to gadm_country';
COMMENT ON COLUMN eqged.grid_point_country.grid_point_id IS 'Foreign key linked to grid_point';

COMMENT ON TABLE eqged.mapping_scheme IS 'mapping scheme table storing all entries of a mapping scheme tree. this table is designed to be flexible in order to store MS tree of arbitrary height, with different type of nodes at each level. see documentation at <URL> for detail explanation of mapping scheme concept';
COMMENT ON TABLE eqged.mapping_scheme_src IS 'Mapping scheme source';
COMMENT ON COLUMN eqged.mapping_scheme.parent_ms_id IS 'pointer to parent mapping scheme record in the same table. this self pointing technique is used to maintain the tree structure';
COMMENT ON COLUMN eqged.mapping_scheme.ms_class_id IS 'building classification';
COMMENT ON COLUMN eqged.mapping_scheme.ms_value IS 'ratio of buildings in the classification';

COMMENT ON TABLE eqged.mapping_scheme_class IS 'building classification, corresponding to a value of a categorical building facet. Example, WOOD. or Low. Classes are placed into the nodes of the mapping scheme tree and associated with the ratio';
COMMENT ON COLUMN eqged.mapping_scheme_class.id IS 'Unique identifier';
COMMENT ON COLUMN eqged.mapping_scheme_class.ms_type_id IS 'foregin key to mapping scheme type';
COMMENT ON COLUMN eqged.mapping_scheme_class.name IS 'Mapping scheme class name';
COMMENT ON COLUMN eqged.mapping_scheme_class.description IS 'Mapping scheme class description';
COMMENT ON COLUMN eqged.mapping_scheme_class.taxonomy IS 'indicates taxonomy of the mapping scheme class. Per current design, classes of distinct taxonomy should not be part of the same tree';
COMMENT ON COLUMN eqged.mapping_scheme_class.ms_type_class_id IS 'mapping scheme id. This ID is recycled for each ms_type_id. the combination of ms_type_id+ms_type_class_id uniquely identifies a mapping scheme class';

COMMENT ON TABLE eqged.mapping_scheme_src IS 'metadata mapping schemes';
COMMENT ON COLUMN eqged.mapping_scheme_src.id IS 'Unique identifier';
COMMENT ON COLUMN eqged.mapping_scheme_src.source IS 'source data from which the mapping scheme is created. Could be but not limited to one of the following:
    - Expert knowledge
    - UNHABITAT housing data
    - PAGER';
COMMENT ON COLUMN eqged.mapping_scheme_src.date_created IS 'Mapping scheme creation date';
COMMENT ON COLUMN eqged.mapping_scheme_src.data_source IS 'Source of the underlying data used to create the mapping scheme.';
COMMENT ON COLUMN eqged.mapping_scheme_src.data_source_date IS 'Date of the underlying data used to create the mapping scheme.';
COMMENT ON COLUMN eqged.mapping_scheme_src.use_notes IS 'description of how this mapping scheme should be used. e.g. which country or which region it should be used, additional restrictions or shortcomings, etc... ';
COMMENT ON COLUMN eqged.mapping_scheme_src.quality IS 'quality measure, should be indication of quality of result. still not well defined.' ;
COMMENT ON COLUMN eqged.mapping_scheme_src.oq_user_id IS 'User identifier of the mapping scheme owner.';
COMMENT ON COLUMN eqged.mapping_scheme_src.taxonomy IS 'taxonomy for the mapping scheme. currently only PAGER is available. We do not anticipate multiple taxonomies used in a single mapping scheme tree';
COMMENT ON COLUMN eqged.mapping_scheme_src.is_urban IS 'Urban/rural flag (TODO this is possibly redundant)'
COMMENT ON COLUMN eqged.mapping_scheme_src.occupancy IS 'occupancy class (TODO should be an id and should probably not be here at all)'

COMMENT ON TABLE eqged.mapping_scheme_type IS 'lookup table for the types of mapping combinations';
COMMENT ON COLUMN eqged.mapping_scheme_type.name IS 'short name description of type of mapping, such as:
    - struct_lv0
    - struct_ht
    - occupancy
    - ...'; 
COMMENT ON COLUMN eqged.mapping_scheme_type.description IS 'detail description of the mapping type. should provide hint of requirements for using the type of mapping.';

COMMENT ON TABLE eqged.pager_to_gem IS 'PAGER-GEM taxonomy conversion table';
COMMENT ON COLUMN eqged.pager_to_gem.id IS 'Unique identifier';
COMMENT ON COLUMN eqged.pager_to_gem.gemid IS 'GEM ID';
COMMENT ON COLUMN eqged.pager_to_gem.gem_building_typology IS 'GEM building typology description';
COMMENT ON COLUMN eqged.pager_to_gem.pager_str IS 'PAGER STR class';
COMMENT ON COLUMN eqged.pager_to_gem.pager_description IS 'PAGER STR class description';
COMMENT ON COLUMN eqged.pager_to_gem.gem_material IS 'GEM material';
COMMENT ON COLUMN eqged.pager_to_gem.gem_material_type IS 'GEM material type';
COMMENT ON COLUMN eqged.pager_to_gem.gem_material_property IS 'GEM material property';
COMMENT ON COLUMN eqged.pager_to_gem.gem_vertical_load_system IS 'GEM vertical load system';
COMMENT ON COLUMN eqged.pager_to_gem.gem_ductility IS 'GEM ductility';
COMMENT ON COLUMN eqged.pager_to_gem.gem_horizontal_load_system IS 'GEM horizontal load system';
COMMENT ON COLUMN eqged.pager_to_gem.gem_height_category IS 'GEM height category';
COMMENT ON COLUMN eqged.pager_to_gem.gem_shorthand_form IS 'GEM taxonomy shorthand form string';

COMMENT ON TABLE eqged.pop_allocation IS 'lookup table to allocate portion of total population according to time of day and urban/rural status for each country. This table is based on PAGER';
COMMENT ON COLUMN eqged.pop_allocation.id IS 'Unique identifier';
COMMENT ON COLUMN eqged.pop_allocation.gadm_country_id IS 'Link to country for which the data applies (foreign key)';
COMMENT ON COLUMN eqged.pop_allocation.is_urban IS 'flag indicating ratio should be used in urban or rural area';
COMMENT ON COLUMN eqged.pop_allocation.day_pop_ratio IS 'ratio of total population assigned as day time non-residential (working) ';
COMMENT ON COLUMN eqged.pop_allocation.night_pop_ratio IS 'ratio of total population for night time residential (at home)';
COMMENT ON COLUMN eqged.pop_allocation.transit_pop_ratio IS 'ratio of total population for transit time (on the road)';
COMMENT ON COLUMN eqged.pop_allocation.occupancy_id IS 'occupancy class (TODO  should be merged with occupancy)';
COMMENT ON COLUMN eqged.pop_allocation.occupancy IS 'TODO occupancy class (TODO  should be merged with occupancy_id)';

COMMENT ON TABLE eqged.population IS 'Table to store population estimates for grid points';
COMMENT ON COLUMN eqged.population.id IS 'Unique identifier';
COMMENT ON COLUMN eqged.population.grid_point_id IS 'Link to grid point (foreign key)';
COMMENT ON COLUMN eqged.population.population_src_id IS 'Link to population data source (foreign key)';
COMMENT ON COLUMN eqged.population.pop_value IS 'population estimate in persons';
COMMENT ON COLUMN eqged.population.pop_quality IS 'population quality estimate: in the case of GRUMP estimates, this is an area measure, in square kilometers, of the spatial unit from which the population was derived. It can be used to mask out points that are deemed to unreliable for a given analysis.';

COMMENT ON TABLE eqged.population_src IS 'Table to store information on a population data source.';
COMMENT ON COLUMN eqged.population_src.id IS 'Unique identifier';
COMMENT ON COLUMN eqged.population_src.source IS 'Project or data provider for a population estimate';
COMMENT ON COLUMN eqged.population_src.description IS 'Description of the population estimate.';
COMMENT ON COLUMN eqged.population_src.notes IS 'Use notes for the population estimate, including information on quality measures, if available.';
COMMENT ON COLUMN eqged.population_src.date IS 'Date that the population data represents';

COMMENT ON TABLE eqged.study_region IS 'metadata describing the region to generate exposure';
COMMENT ON COLUMN eqged.study_region.id IS 'Unique identifier';
COMMENT ON COLUMN eqged.study_region.name IS 'Study region name';
COMMENT ON COLUMN eqged.study_region.date_created IS 'Creation date';
COMMENT ON COLUMN eqged.study_region.notes IS 'Usage notes for the study region';
COMMENT ON COLUMN eqged.study_region.oq_user_id IS 'User identifier of the study region owner'

COMMENT ON VIEW eqged.view_mapping_scheme IS 'Internal view used for mapping scheme management';

COMMENT ON TABLE pshai.complex_fault IS 'A complex (fault) geometry, in essence a sequence of fault edges. However, we only support a single fault edge at present.';
COMMENT ON COLUMN pshai.complex_fault.gid IS 'An alpha-numeric identifier for this complex fault geometry.';
COMMENT ON COLUMN pshai.complex_fault.mfd_tgr_id IS 'Foreign key to a magnitude frequency distribution (truncated Gutenberg-Richter).';
COMMENT ON COLUMN pshai.complex_fault.mfd_evd_id IS 'Foreign key to a magnitude frequency distribution (evenly discretized).';
COMMENT ON COLUMN pshai.complex_fault.fault_edge_id IS 'Foreign key to a fault edge.';
COMMENT ON COLUMN pshai.complex_fault.outline IS 'The outline of the fault surface, computed by using the top/bottom fault edges.';

COMMENT ON VIEW pshai.complex_rupture IS 'A complex rupture view, needed for opengeo server integration.';
COMMENT ON VIEW pshai.complex_source IS 'A complex source view, needed for opengeo server integration.';

COMMENT ON TABLE pshai.fault_edge IS 'Part of a complex (fault) geometry, describes the top and the bottom seismic edges.';
COMMENT ON COLUMN pshai.fault_edge.bottom IS 'Bottom fault edge.';
COMMENT ON COLUMN pshai.fault_edge.top IS 'Top fault edge.';

COMMENT ON TABLE pshai.focal_mechanism IS 'Holds strike, dip and rake values with the respective constraints.';

COMMENT ON TABLE pshai.mfd_evd IS 'Magnitude frequency distribution, evenly discretized.';
COMMENT ON COLUMN pshai.mfd_evd.magnitude_type IS 'Magnitude type i.e. one of:
    - body wave magnitude (Mb)
    - duration magnitude (Md)
    - local magnitude (Ml)
    - surface wave magnitude (Ms)
    - moment magnitude (Mw)';
COMMENT ON COLUMN pshai.mfd_evd.min_val IS 'Minimum magnitude value.';
COMMENT ON COLUMN pshai.mfd_evd.max_val IS 'Maximum magnitude value (will be derived/calculated for evenly discretized magnitude frequency distributions).';

COMMENT ON TABLE pshai.mfd_tgr IS 'Magnitude frequency distribution, truncated Gutenberg-Richter.';
COMMENT ON COLUMN pshai.mfd_tgr.magnitude_type IS 'Magnitude type i.e. one of:
    - body wave magnitude (Mb)
    - duration magnitude (Md)
    - local magnitude (Ml)
    - surface wave magnitude (Ms)
    - moment magnitude (Mw)';
COMMENT ON COLUMN pshai.mfd_tgr.min_val IS 'Minimum magnitude value.';
COMMENT ON COLUMN pshai.mfd_tgr.max_val IS 'Maximum magnitude value.';

COMMENT ON TABLE pshai.r_depth_distr IS 'Rupture depth distribution.';
COMMENT ON COLUMN pshai.r_depth_distr.magnitude_type IS 'Magnitude type i.e. one of:
    - body wave magnitude (Mb)
    - duration magnitude (Md)
    - local magnitude (Ml)
    - surface wave magnitude (Ms)
    - moment magnitude (Mw)';

COMMENT ON TABLE pshai.r_rate_mdl IS 'Rupture rate model.';

COMMENT ON TABLE pshai.rupture IS 'A rupture, can be based on a point or a complex or simple fault.';
COMMENT ON COLUMN pshai.rupture.si_type IS 'The rupture''s seismic input type: can be one of: point, complex or simple.';
COMMENT ON COLUMN pshai.rupture.magnitude_type IS 'Magnitude type i.e. one of:
    - body wave magnitude (Mb)
    - duration magnitude (Md)
    - local magnitude (Ml)
    - surface wave magnitude (Ms)
    - moment magnitude (Mw)';
COMMENT ON COLUMN pshai.rupture.tectonic_region IS 'Tectonic region type i.e. one of:
    - Active Shallow Crust (active)
    - Stable Shallow Crust (stable)
    - Subduction Interface (interface)
    - Subduction IntraSlab (intraslab)
    - Volcanic             (volcanic)';

COMMENT ON TABLE pshai.simple_fault IS 'A simple fault geometry.';
COMMENT ON COLUMN pshai.simple_fault.dip IS 'The fault''s inclination angle with respect to the plane.';
COMMENT ON COLUMN pshai.simple_fault.upper_depth IS 'The upper seismogenic depth.';
COMMENT ON COLUMN pshai.simple_fault.lower_depth IS 'The lower seismogenic depth.';
COMMENT ON COLUMN pshai.simple_fault.outline IS 'The outline of the fault surface, computed by using the dip and the upper/lower seismogenic depth.';

COMMENT ON VIEW pshai.simple_rupture IS 'A simple rupture view, needed for opengeo server integration.';
COMMENT ON VIEW pshai.simple_source IS 'A simple source view, needed for opengeo server integration.';
COMMENT ON TABLE pshai.source IS 'A seismic source, can be based on a point, area or a complex or simple fault.';
COMMENT ON COLUMN pshai.source.si_type IS 'The source''s seismic input type: can be one of: area, point, complex or simple.';
COMMENT ON COLUMN pshai.source.tectonic_region IS 'Tectonic region type i.e. one of:
    - Active Shallow Crust (active)
    - Stable Shallow Crust (stable)
    - Subduction Interface (interface)
    - Subduction IntraSlab (intraslab)
    - Volcanic             (volcanic)';

COMMENT ON TABLE uiapi.hazard_map_data IS 'Holds location/IML data for hazard maps';
COMMENT ON COLUMN uiapi.hazard_map_data.output_id IS 'The foreign key to the output record that represents the corresponding hazard map.';

COMMENT ON TABLE uiapi.input IS 'A single OpenQuake input file uploaded by the user';
COMMENT ON COLUMN uiapi.input.input_type IS 'Input file type, one of:
    - source model file (source)
    - source logic tree (lt_source)
    - GMPE logic tree (lt_gmpe)
    - exposure file (exposure)
    - vulnerability file (vulnerability)';
COMMENT ON COLUMN uiapi.input.path IS 'The full path of the input file on the server';
COMMENT ON COLUMN uiapi.input.size IS 'Number of bytes in file';

COMMENT ON TABLE uiapi.loss_map_data IS 'Holds location/loss data for loss maps.';
COMMENT ON COLUMN uiapi.loss_map_data.output_id IS 'The foreign key to the output record that represents the corresponding loss map.';

COMMENT ON TABLE uiapi.oq_job IS 'Date related to an OpenQuake job that was created in the UI.';
COMMENT ON COLUMN uiapi.oq_job.description IS 'A description of the OpenQuake job, allows users to browse jobs and their inputs/outputs at a later point.';
COMMENT ON COLUMN uiapi.upload.job_pid IS 'The process id (PID) of the OpenQuake engine runner process';
COMMENT ON COLUMN uiapi.oq_job.job_type IS 'One of: classical, event_based or deterministic.';
COMMENT ON COLUMN uiapi.oq_job.status IS 'One of: pending, running, failed or succeeded.';
COMMENT ON COLUMN uiapi.oq_job.duration IS 'The job''s duration in seconds (only available once the jobs terminates).';

COMMENT ON TABLE uiapi.oq_params IS 'Holds the parameters needed to invoke the OpenQuake engine.';
COMMENT ON COLUMN uiapi.oq_params.job_type IS 'One of: classical, event_based or deterministic.';
COMMENT ON COLUMN uiapi.oq_params.histories IS 'Number of seismicity histories';
COMMENT ON COLUMN uiapi.oq_params.imls IS 'Intensity measure levels';
COMMENT ON COLUMN uiapi.oq_params.imt IS 'Intensity measure type, one of:
    - peak ground acceleration (pga)
    - spectral acceleration (sa)
    - peak ground velocity (pgv)
    - peak ground displacement (pgd)';
COMMENT ON COLUMN uiapi.oq_params.poes IS 'Probabilities of exceedence';

COMMENT ON TABLE uiapi.output IS 'A single OpenQuake calculation engine output file.';
COMMENT ON COLUMN uiapi.output.output_type IS 'Output file type, one of:
    - unknown
    - hazard_curve
    - hazard_map
    - loss_curve
    - loss_map';
COMMENT ON COLUMN uiapi.output.shapefile_path IS 'The full path of the shapefile generated for a hazard or loss map.';
COMMENT ON COLUMN uiapi.output.path IS 'The full path of the output file on the server.';

COMMENT ON TABLE uiapi.upload IS 'A batch of OpenQuake input files uploaded by the user';
COMMENT ON COLUMN uiapi.upload.job_pid IS 'The process id (PID) of the NRML loader process';
COMMENT ON COLUMN uiapi.upload.path IS 'The directory where the input files belonging to a batch live on the server';
COMMENT ON COLUMN uiapi.upload.status IS 'One of: pending, running, failed or succeeded.';
