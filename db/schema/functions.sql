/*
  Functions used in the OpenQuake database.

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

CREATE OR REPLACE FUNCTION format_exc(operation TEXT, error TEXT, tab_name TEXT) RETURNS TEXT AS $$
BEGIN
    RETURN operation || ': error: ' || error || ' (' || tab_name || ')';
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION check_rupture_sources() RETURNS TRIGGER
LANGUAGE plpgsql AS
$$
DECLARE
    num_sources INTEGER := 0;
    violations TEXT := '';
    exception_msg TEXT := '';
BEGIN
    IF NEW.point IS NOT NULL THEN
        num_sources := num_sources + 1;
        violations = 'point';
    END IF;
    IF NEW.simple_fault_id IS NOT NULL THEN
        num_sources := num_sources + 1;
        violations = violations || ' simple_fault_id';
    END IF;
    IF NEW.complex_fault_id IS NOT NULL THEN
        num_sources := num_sources + 1;
        violations = violations || ' complex_fault_id';
    END IF;
    IF num_sources = 0 THEN
        exception_msg := format_exc(TG_OP, 'no seismic inputs', TG_TABLE_NAME);
        RAISE '%', exception_msg;
    ELSE
        IF num_sources > 1 THEN
            exception_msg := format_exc(TG_OP, 'more than one seismic input <' || violations || '>', TG_TABLE_NAME);
            RAISE '%', exception_msg;
        END IF;
    END IF;

    IF NEW.point IS NOT NULL AND NEW.si_type != 'point' THEN
        exception_msg := format_exc(TG_OP, 'type should be point <' || NEW.si_type || '>', TG_TABLE_NAME);
        RAISE '%', exception_msg;
    END IF;
    IF NEW.simple_fault_id IS NOT NULL AND NEW.si_type != 'simple' THEN
        exception_msg := format_exc(TG_OP, 'type should be simple <' || NEW.si_type || '>', TG_TABLE_NAME);
        RAISE '%', exception_msg;
    END IF;
    IF NEW.complex_fault_id IS NOT NULL AND NEW.si_type != 'complex' THEN
        exception_msg := format_exc(TG_OP, 'type should be complex <' || NEW.si_type || '>', TG_TABLE_NAME);
        RAISE '%', exception_msg;
    END IF;

    IF TG_OP = 'UPDATE' THEN
        NEW.last_update := timezone('UTC'::text, now());
    END IF;
    RETURN NEW;
END;
$$;

COMMENT ON FUNCTION check_rupture_sources() IS
'Make sure a rupture only has one source (point, simple or complex fault).';

CREATE OR REPLACE FUNCTION check_source_sources() RETURNS TRIGGER
LANGUAGE plpgsql AS
$$
DECLARE
    num_sources INTEGER := 0;
    violations TEXT := '';
    exception_msg TEXT := '';
BEGIN
    IF NEW.point IS NOT NULL THEN
        num_sources := num_sources + 1;
        violations = 'point';
    END IF;
    IF NEW.area IS NOT NULL THEN
        num_sources := num_sources + 1;
        violations = violations || ' area';
    END IF;
    IF NEW.simple_fault_id IS NOT NULL THEN
        num_sources := num_sources + 1;
        violations = violations || ' simple_fault_id';
    END IF;
    IF NEW.complex_fault_id IS NOT NULL THEN
        num_sources := num_sources + 1;
        violations = violations || ' complex_fault_id';
    END IF;
    IF num_sources = 0 THEN
        exception_msg := format_exc(TG_OP, 'no seismic inputs', TG_TABLE_NAME);
        RAISE '%', exception_msg;
    ELSE
        IF num_sources > 1 THEN
            exception_msg := format_exc(TG_OP, 'more than one seismic input <' || violations || '>', TG_TABLE_NAME);
            RAISE '%', exception_msg;
        END IF;
    END IF;

    IF NEW.point IS NOT NULL OR NEW.area IS NOT NULL THEN
        IF NEW.hypocentral_depth IS NULL THEN
            exception_msg := format_exc(TG_OP, 'hypocentral_depth missing', TG_TABLE_NAME);
            RAISE '%', exception_msg;
        END IF;
        IF NEW.r_depth_distr_id IS NULL THEN
            exception_msg := format_exc(TG_OP, 'r_depth_distr_id missing', TG_TABLE_NAME);
            RAISE '%', exception_msg;
        END IF;
    ELSE
        IF NEW.hypocentral_depth IS NOT NULL THEN
            exception_msg := format_exc(TG_OP, 'hypocentral_depth set', TG_TABLE_NAME);
            RAISE '%', exception_msg;
        END IF;
        IF NEW.r_depth_distr_id IS NOT NULL THEN
            exception_msg := format_exc(TG_OP, 'r_depth_distr_id set', TG_TABLE_NAME);
            RAISE '%', exception_msg;
        END IF;
    END IF;

    IF NEW.point IS NOT NULL AND NEW.si_type != 'point' THEN
        exception_msg := format_exc(TG_OP, 'type should be point <' || NEW.si_type || '>', TG_TABLE_NAME);
        RAISE '%', exception_msg;
    END IF;
    IF NEW.area IS NOT NULL AND NEW.si_type != 'area' THEN
        exception_msg := format_exc(TG_OP, 'type should be area <' || NEW.si_type || '>', TG_TABLE_NAME);
        RAISE '%', exception_msg;
    END IF;
    IF NEW.simple_fault_id IS NOT NULL AND NEW.si_type != 'simple' THEN
        exception_msg := format_exc(TG_OP, 'type should be simple <' || NEW.si_type || '>', TG_TABLE_NAME);
        RAISE '%', exception_msg;
    END IF;
    IF NEW.complex_fault_id IS NOT NULL AND NEW.si_type != 'complex' THEN
        exception_msg := format_exc(TG_OP, 'type should be complex <' || NEW.si_type || '>', TG_TABLE_NAME);
        RAISE '%', exception_msg;
    END IF;

    IF TG_OP = 'UPDATE' THEN
        NEW.last_update := timezone('UTC'::text, now());
    END IF;
    RETURN NEW;
END;
$$;

COMMENT ON FUNCTION check_source_sources() IS
'Make sure a seismic source only has one source (area, point, simple or complex fault).';

CREATE OR REPLACE FUNCTION check_only_one_mfd_set() RETURNS TRIGGER
LANGUAGE plpgsql AS
$$
DECLARE
    num_sources INTEGER := 0;
    exception_msg TEXT := '';
BEGIN
    IF NEW.mfd_tgr_id IS NOT NULL THEN
        -- truncated Gutenberg-Richter
        num_sources := num_sources + 1;
    END IF;
    IF NEW.mfd_evd_id IS NOT NULL THEN
        -- evenly discretized
        num_sources := num_sources + 1;
    END IF;
    IF num_sources = 0 THEN
        exception_msg := format_exc(TG_OP, 'no magnitude frequency distribution', TG_TABLE_NAME);
        RAISE '%', exception_msg;
    ELSE
        IF num_sources > 1 THEN
            exception_msg := format_exc(TG_OP, 'more than one magnitude frequency distribution', TG_TABLE_NAME);
            RAISE '%', exception_msg;
        END IF;
    END IF;

    IF TG_OP = 'UPDATE' THEN
        NEW.last_update := timezone('UTC'::text, now());
    END IF;
    RETURN NEW;
END;
$$;

COMMENT ON FUNCTION check_only_one_mfd_set() IS
'Make sure only one magnitude frequency distribution is set.';

CREATE OR REPLACE FUNCTION check_magnitude_data() RETURNS TRIGGER
LANGUAGE plpgsql AS
$$
DECLARE
    num_sources INTEGER := 0;
    exception_msg TEXT := '';
BEGIN
    IF NEW.mb_val IS NOT NULL THEN
        num_sources := num_sources + 1;
    END IF;
    IF NEW.ml_val IS NOT NULL THEN
        num_sources := num_sources + 1;
    END IF;
    IF NEW.ms_val IS NOT NULL THEN
        num_sources := num_sources + 1;
    END IF;
    IF NEW.mw_val IS NOT NULL THEN
        num_sources := num_sources + 1;
    END IF;
    IF num_sources = 0 THEN
        exception_msg := format_exc(TG_OP, 'no magnitude value set', TG_TABLE_NAME);
        RAISE '%', exception_msg;
    END IF;

    IF TG_OP = 'UPDATE' THEN
        NEW.last_update := timezone('UTC'::text, now());
    END IF;
    RETURN NEW;
END;
$$;

COMMENT ON FUNCTION check_magnitude_data() IS
'Make sure that at least one magnitude value is set.';

CREATE OR REPLACE FUNCTION eqged.build_gadm_admin_1(gadm_admin_1_id numeric) RETURNS void
LANGUAGE plpgsql AS
$$
DECLARE
  bb_xmin float;
  bb_xmax float;
  bb_ymin float;
  bb_ymax float;
BEGIN
  SELECT INTO bb_xmin ST_XMin(the_geom) FROM eqged.gadm_admin_1 WHERE id = gadm_admin_1_id;
  SELECT INTO bb_xmax ST_XMax(the_geom) FROM eqged.gadm_admin_1 WHERE id = gadm_admin_1_id;
  SELECT INTO bb_ymin ST_YMin(the_geom) FROM eqged.gadm_admin_1 WHERE id = gadm_admin_1_id;
  SELECT INTO bb_ymax ST_YMax(the_geom) FROM eqged.gadm_admin_1 WHERE id = gadm_admin_1_id;
  INSERT INTO eqged.grid_point_admin_1
    SELECT a.id, b.id FROM
      (SELECT id, the_geom FROM eqged.grid_point
        WHERE lon >= bb_xmin AND lon <= bb_xmax AND lat >= bb_ymin AND lat <= bb_ymax) a,
      eqged.gadm_admin_1 b
      WHERE b.id = gadm_admin_1_id AND ST_Contains(b.the_geom, a.the_geom);
END;
$$;

COMMENT ON FUNCTION eqged.build_gadm_admin_1() IS
'Populate eqged.grid_point_admin_1 for a given GADM region, matching the grid points to the region geometry.';

CREATE OR REPLACE FUNCTION eqged.build_gadm_admin_2(gadm_admin_2_id numeric) RETURNS void
LANGUAGE plpgsql AS
$$
DECLARE
  bb_xmin float;
  bb_xmax float;
  bb_ymin float;
  bb_ymax float;
BEGIN
  SELECT INTO bb_xmin ST_XMin(the_geom) FROM eqged.gadm_admin_2 WHERE id = gadm_admin_2_id;
  SELECT INTO bb_xmax ST_XMax(the_geom) FROM eqged.gadm_admin_2 WHERE id = gadm_admin_2_id;
  SELECT INTO bb_ymin ST_YMin(the_geom) FROM eqged.gadm_admin_2 WHERE id = gadm_admin_2_id;
  SELECT INTO bb_ymax ST_YMax(the_geom) FROM eqged.gadm_admin_2 WHERE id = gadm_admin_2_id;
  INSERT INTO eqged.grid_point_admin_2
    SELECT a.id, b.id FROM
      (SELECT id, the_geom FROM eqged.grid_point
        WHERE lon >= bb_xmin AND lon <= bb_xmax AND lat >= bb_ymin AND lat <= bb_ymax) a,
      eqged.gadm_admin_2 b
      WHERE b.id = gadm_admin_2_id AND ST_Contains(b.the_geom, a.the_geom);
END;
$$;

COMMENT ON FUNCTION eqged.build_gadm_admin_2() IS
'Populate eqged.grid_point_admin_2 for a given GADM region, matching the grid points to the region geometry.';

CREATE OR REPLACE FUNCTION eqged.build_gadm_country(gadm_country_id numeric) RETURNS void
LANGUAGE plpgsql AS
$$
DECLARE
  bb_xmin float;
  bb_xmax float;
  bb_ymin float;
  bb_ymax float;
BEGIN
  SELECT INTO bb_xmin ST_XMin(the_geom) FROM eqged.gadm_country WHERE id = gadm_country_id;
  SELECT INTO bb_xmax ST_XMax(the_geom) FROM eqged.gadm_country WHERE id = gadm_country_id;
  SELECT INTO bb_ymin ST_YMin(the_geom) FROM eqged.gadm_country WHERE id = gadm_country_id;
  SELECT INTO bb_ymax ST_YMax(the_geom) FROM eqged.gadm_country WHERE id = gadm_country_id;
  INSERT INTO eqged.grid_point_country
    SELECT a.id, b.id FROM
      (SELECT id, the_geom FROM eqged.grid_point
        WHERE lon >= bb_xmin AND lon <= bb_xmax AND lat >= bb_ymin AND lat <= bb_ymax) a,
      eqged.gadm_country b
      WHERE b.id = gadm_country_id AND ST_Contains(b.the_geom, a.the_geom);
END;
$$;

COMMENT ON FUNCTION eqged.build_gadm_country() IS
'Populate eqged.grid_point_country for a given GADM region, matching the grid points to the region geometry.';

CREATE OR REPLACE FUNCTION eqged.fill_agg_build_infra(in_study_region_id numeric) RETURNS void
LANGUAGE plpgsql AS
$$
declare
	mapping_scheme_record RECORD;
begin	
--
-- script for applying mapping scheme for creating GED level1 database
--
-- population data tables
-- eqged.grid_points: id and geometry 
-- eqged.grid_point_attributes: urban condition flag,
-- eqged.grid_point_country: gadm_country_id
-- eqged.population/eqged.population_src: actual population for grid cell
-- eqged.pop_allocation: ratio of population for different conditions (urban, time of day, occupancy)
--
-- mapping scheme tables
-- eqged.mapping_scheme_src, eqged.mapping_scheme, eqged.mapping_scheme_types, eqged.mapping_scheme_classes:
-- 	contain entire mapping scheme tree
-- 	these tables are combined into eqged.temp_mapping_schemes, eqged.temp_mapping_schemes has the correct format 
-- 
-- link tables
-- study_regions: each study region contains multiple mapping schemes that can be applied to different
-- 	sub-regions 
-- agg_build_infra_src: establish the links between population data and mapping schemes

	-- clear existing results
	delete from eqged.gem_exposure where study_region_id=in_study_region_id;
	delete from eqged.agg_build_infra where study_region_id=in_study_region_id;
	delete from eqged.agg_build_infra_pop where study_region_id=in_study_region_id;
	delete from eqged.agg_build_infra_pop_ratio where study_region_id=in_study_region_id;

	-- create temporary table for storing data
	-- after process is completed transfer data into 'eqged.agg_build_infra' table
	drop table if exists agg_build_infra_temp;
    	CREATE TEMPORARY TABLE agg_build_infra_temp
	(
		grid_point_id integer NOT NULL,
		gadm_country_id integer NOT NULL,
		grid_point_country_id integer, 	-- this field currently does not exist in eqged.grid_point_county, need to add
		population_id integer NOT NULL,
		agg_build_infra_src_id integer NOT NULL,

		mapping_scheme_id integer not null,
		ms_value float not null,

		struct_ms_class character varying,
		height_ms_class character varying,
		occ_ms_class character varying,
		age_ms_class character varying,
		num_buildings double precision,
		struct_area double precision,
		day_pop_ratio double precision,
		night_pop_ratio double precision,
		transit_pop_ratio double precision,
		day_pop double precision,
		night_pop double precision,
		transit_pop double precision
	)
	TABLESPACE eqged_ts;

	-- select study regions and all associated mapping schemes
	-- loop through each mapping scheme and apply to grids
	for mapping_scheme_record in 
		select t1.id, mapping_scheme_src_id, gadm_country_id, the_geom, t2.is_urban
			from eqged.agg_build_infra_src t1 inner join eqged.mapping_scheme_src t2 on t1.mapping_scheme_src_id=t2.id 
		where study_region_id = in_study_region_id
		loop
		
		raise notice 'process mapping scheme %, agg_build_infra_src_id %, is_urban %', 
			mapping_scheme_record.mapping_scheme_src_id, mapping_scheme_record.id, mapping_scheme_record.is_urban;


		-- FINAL
		insert into eqged.agg_build_infra (study_region_id, agg_build_infra_src_id, mapping_scheme_id, compound_ms_value) 
		select 
			in_study_region_id, mapping_scheme_record.id, 
			case when t4_ms_type_id is not null then t4_ms_id else t3_ms_id end mapping_scheme_id, ms_value 
		from eqged.temp_mapping_schemes where mapping_scheme_src_id=mapping_scheme_record.mapping_scheme_src_id;

		IF (mapping_scheme_record.gadm_country_id IS NOT NULL) THEN
			-- if the mapping scheme applies to the entire country, then we can 
			-- use a shortcut to skips the point-n-polygon operation to
			-- retrieve all points within the area covered by the mapping scheme
			raise notice '    using shortcut';
			
			insert into eqged.agg_build_infra_pop_ratio 
				(study_region_id, gadm_country_id, grid_point_id, agg_build_infra_id, 
				 occupancy, day_pop_ratio, night_pop_ratio, transit_pop_ratio)
			select  in_study_region_id, t1.gadm_country_id, t1.grid_point_id, t2.id, occupancy,
				t2.compound_ms_value*day_pop_ratio, t2.compound_ms_value*night_pop_ratio, t2.compound_ms_value*transit_pop_ratio
			from 
				( 
				select tt1.grid_point_id, tt1.gadm_country_id
				from eqged.grid_point_country tt1
					    inner join eqged.grid_point_attribute tt2 on tt1.grid_point_id=tt2.grid_point_id
					    where tt1.gadm_country_id = mapping_scheme_record.gadm_country_id and tt2.is_urban = mapping_scheme_record.is_urban
				) t1 
				cross join 
				-- attach agg_build_infra (mapping scheme)
				(select id, study_region_id, agg_build_infra_src_id, compound_ms_value from  eqged.agg_build_infra where
					study_region_id = in_study_region_id and agg_build_infra_src_id = mapping_scheme_record.id )t2
				-- apply population allocation for country
				inner join (select * from eqged.pop_allocation 
							where is_urban and gadm_country_id=mapping_scheme_record.gadm_country_id
							and occupancy <> 'Outdoor') t3 on t1.gadm_country_id=t3.gadm_country_id;						
		ELSE
			-- only part of the country uses the mapping scheme
			-- perform point-n-polygon to retrieve all points (very costly)
			-- currently, action is performed twice, probably need some optimization
			-- to store into temporary table to avoid repeating.
			raise notice '    using point polygon';		
			
			insert into eqged.agg_build_infra_pop_ratio 
				(study_region_id, gadm_country_id, grid_point_id, agg_build_infra_id, 
				 occupancy, day_pop_ratio, night_pop_ratio, transit_pop_ratio)
			select  in_study_region_id, t1.gadm_country_id, t1.grid_point_id, t2.id, occupancy,
				t2.compound_ms_value*day_pop_ratio, t2.compound_ms_value*night_pop_ratio, t2.compound_ms_value*transit_pop_ratio
			from 
				( 
				select tt1.grid_point_id, tt1.gadm_country_id
				from eqged.grid_point_country tt1
					    inner join eqged.grid_point_attribute tt2 on tt1.grid_point_id=tt2.grid_point_id
					    where tt2.is_urban = mapping_scheme_record.is_urban
						and st_contains(mapping_scheme_record.the_geom, the_geom)
				) t1 
				cross join 
				-- attach agg_build_infra (mapping scheme)
				(select id, study_region_id, agg_build_infra_src_id, compound_ms_value from  eqged.agg_build_infra where
					study_region_id = in_study_region_id and agg_build_infra_src_id = mapping_scheme_record.id )t2
				-- apply population allocation for country
				inner join (select * from eqged.pop_allocation 
							where is_urban and gadm_country_id=mapping_scheme_record.gadm_country_id
							and occupancy <> 'Outdoor') t3 on t1.gadm_country_id=t3.gadm_country_id;		
		END IF;
	end loop;

	raise notice '    insert into agg_build_infra_pop';		
			
	-- insert into agg_build_infra_pop
	insert into eqged.agg_build_infra_pop 
		(study_region_id, agg_build_infra_pop_ratio_id, population_id,
		day_pop, night_pop, transit_pop, num_buildings, struct_area)
	select in_study_region_id, t1.id, t2.id, 
		t1.day_pop_ratio*t2.pop_value, t1.night_pop_ratio*t2.pop_value, t1.transit_pop_ratio*t2.pop_value,
		0, 0
	from 
		(select * from eqged.agg_build_infra_pop_ratio where study_region_id=in_study_region_id) t1
		inner join eqged.population t2 on t1.grid_point_id=t2.grid_point_id;
			
	-- update flat table eqged.gem_exposure 
	raise notice '    build flat table';
	insert into eqged.gem_exposure 
		(study_region_id, grid_point_id, grid_point_the_gem, grid_point_lat, 
		grid_point_lon, gadm_country_name, gadm_country_iso, gadm_admin_1_name, 
		gadm_admin1_engtype, gadm_admin_2_name, gadm_admin2_engtype, 
		population_population_src_id, population_pop_value, population_pop_quality, 
		grid_point_attribute_land_area, grid_point_attribute_is_urban, 
		grid_point_attribute_urban_measure_quality, cresta_zone_zone_name, 
		cresta_zon_subzone_name, ms_class_name_struct, ms_class_name_height, 
		ms_class_name_occ, ms_class_name_age, ms_value, gem_material, 
		gem_material_type, gem_material_property, gem_vertical_load_system, 
		gem_ductility, gem_horizontal_load_system, gem_height_category, 
		gem_shorthand_form, agg_build_infra_pop_ratio_day_pop_ratio, 
		agg_build_infra_pop_ratio_night_pop_ratio, agg_build_infra_pop_ratio_transit_pop_ratio, 
		agg_build_infra_pop_day_pop, agg_build_infra_pop_night_pop, agg_build_infra_pop_transit_pop, 
		agg_build_infra_pop_num_buildings, agg_build_infra_pop_struct_area)
	select  in_study_region_id, ar.grid_point_id, g.the_geom grid_point_the_gem, g.lat grid_point_lat, g.lon grid_point_lon,
		gc.name gadm_country_name, gc.iso gadm_country_iso, gc1.name gadm_admin_1_name, gc1.engtype gadm_admin1_engtype, gc2.name gadm_admin_2_name, gc2.engtype gadm_admin2_engtype, 
		po.population_src_id population_population_src_id, po.pop_value population_pop_value, po.pop_quality population_pop_quality, 
		ga.land_area grid_point_attribute_land_area, ga.is_urban grid_point_attribute_is_urban, ga.urban_measure_quality grid_point_attribute_urban_measure_quality,
		cc1.zone_name cresta_zone_zone_name, cc2.zone_name cresta_zon_subzone_name, 
		struct_ms_class ms_class_name_struct, height_ms_class ms_class_name_height, 
		ar.occupancy ms_class_name_occ, '' ms_class_name_age, ai.compound_ms_value ms_value,
		pg.gem_material, pg.gem_material_type, pg.gem_material_property, 
		pg.gem_vertical_load_system, pg.gem_ductility, pg.gem_horizontal_load_system, pg.gem_height_category, pg.gem_shorthand_form,
		ar.day_pop_ratio agg_build_infra_pop_ratio_day_pop_ratio, ar.night_pop_ratio agg_build_infra_pop_ratio_night_pop_ratio, ar.transit_pop_ratio agg_build_infra_pop_ratio_transit_pop_ratio,
		ap.day_pop agg_build_infra_pop_day_pop, ap.night_pop agg_build_infra_pop_night_pop, ap.transit_pop agg_build_infra_pop_transit_pop,
		ap.num_buildings agg_build_infra_pop_num_buildings, ap.struct_area agg_build_infra_pop_struct_area		
	from 
		(select * from eqged.agg_build_infra_pop where study_region_id=in_study_region_id) ap
		inner join eqged.population po on ap.population_id=po.id
		inner join (select * from eqged.agg_build_infra_pop_ratio where study_region_id=in_study_region_id) ar on ap.agg_build_infra_pop_ratio_id=ar.id
			inner join eqged.grid_point g on ar.grid_point_id=g.id
		inner join (select * from eqged.agg_build_infra where study_region_id=in_study_region_id) ai on ar.agg_build_infra_id = ai.id
			inner join 
			(select case when t4_ms_type_id is not null then t4_ms_id else t3_ms_id end mapping_scheme_id, 
				case when t4_ms_type_id is not null then t4_ms_name else t3_ms_name end as struct_ms_class,
				case when t4_ms_type_id is not null then substring(t4_ms_name from char_length(t4_ms_name) for 1) else 'U' end as height_ms_class				
			from eqged.temp_mapping_schemes) tm on ai.mapping_scheme_id=tm.mapping_scheme_id
		inner join eqged.grid_point_attribute ga on ar.grid_point_id = ga.grid_point_id
			left join eqged.cresta_zone cc1 on ga.cresta_zone = cc1.id
			left join eqged.cresta_zone cc2 on ga.cresta_subzone = cc2.id				
		inner join eqged.gadm_country gc on ar.gadm_country_id=gc.id
			left join eqged.grid_point_admin_1 gp1 on ar.grid_point_id=gp1.grid_point_id left join eqged.gadm_admin_1 gc1 on gp1.gadm_admin_1_id=gc1.id
			left join eqged.grid_point_admin_2 gp2 on ar.grid_point_id=gp2.grid_point_id left join eqged.gadm_admin_1 gc2 on gp2.gadm_admin_2_id=gc2.id
		left join eqged.pager_to_gem pg on tm.struct_ms_class = pg.pager_str;

	raise notice '    processing completed.';
end;
$$;

COMMENT ON FUNCTION eqged.fill_agg_build_infra() IS
'Builds exposure and populates eqged.agg_build_infra* and eqged.gem_exposure.';

CREATE OR REPLACE FUNCTION eqged.make_joined() RETURNS text
LANGUAGE plpgsql AS
$$
DECLARE
	myquery text;
	innerquery text;
	tabcount integer;
	counter integer := 1;
	tabname char(2);
	typetabname char(3);
	from_clause text;
BEGIN
	drop table if exists eqged_temp_mapping_scheme;
	drop table if exists eqged.temp_mapping_schemes;
	create temporary table eqged_temp_mapping_scheme as select * from eqged.view_mapping_scheme;

	innerquery := eqged.make_ms_query(true);

	raise notice 'innerquery';	
	raise notice '%', innerquery;
	myquery := 'create table eqged.temp_mapping_schemes as SELECT u1.* ';
	from_clause := ' FROM (' || innerquery || ') u1 ';

	select count(*) from (select parent_ms_type_id, ms_type_id from eqged_temp_mapping_scheme 
	group by parent_ms_type_id, ms_type_id 
	order by parent_ms_type_id, ms_type_id) t into tabcount;
	for counter in 1 .. tabcount loop
		tabname := 't' || counter;
		typetabname := 'u' || (counter + 10);

		myquery := myquery || ', ' || typetabname || '.name as t' || counter || '_type_name';
		from_clause := from_clause || ' LEFT JOIN eqged.mapping_scheme_type ' || typetabname || ' on u1.t' || counter || '_ms_type_id=' || typetabname || '.id ';
	end loop;
	myquery := myquery || from_clause;
	raise notice '%',  myquery ;
	-- test
	-- select eqged.make_joined()
	execute myquery;
	drop table if exists eqged_temp_mapping_scheme;
	return myquery;
END;
$$;

COMMENT ON FUNCTION eqged.make_joined() IS
'Generate eqged.temp_mapping_schemes, a combined flattened mapping scheme table used by eqged.fill_agg_build_infra().';

CREATE OR REPLACE FUNCTION eqged.make_ms_query(use_temp_table boolean) RETURNS text
LANGUAGE plpgsql AS
$$
DECLARE
        my_parent_type integer;
        my_type integer;
        counter integer := 1;
        myrow RECORD ;
        myquery text := 'SELECT t1.mapping_scheme_src_id, ';
        tname char(2);
        oldtname char(2);
        from_clause text := ' FROM ';
        product text := '';
        ms_table text;
BEGIN
	IF use_temp_table THEN
		ms_table := 'eqged_temp_mapping_scheme';
	ELSE
		ms_table := 'eqged.view_mapping_scheme';
	END IF;
	for myrow in 
	select ms_type_id from eqged.view_mapping_scheme group by ms_type_id order by ms_type_id
	loop
		my_type := myrow.ms_type_id;
		tname := 't' || counter; -- table identifier (e.g. t1)
		myquery := myquery || tname || '.id AS ' || tname || '_ms_id, ' || tname || '.ms_type_id AS ' || tname || '_ms_type_id, ' || tname || '.ms_class_id AS ' || tname || '_ms_class_id, ' || tname || '.ms_name AS ' || tname || '_ms_name, ' || ' CASE WHEN ' || tname || '.ms_value IS NULL THEN 1 ELSE ' || tname || '.ms_value END AS ' || tname || '_ms_value, ';

		if counter > 1 then
			from_clause := from_clause || ' LEFT JOIN ';
			product := product || ' * ';
		end if;

		product := product || 'CASE WHEN ' || tname || '.ms_value IS NULL THEN 1 ELSE ' || tname || '.ms_value END';
		from_clause := from_clause || '( SELECT * FROM ' || ms_table || ' WHERE ms_type_id=' || my_type || ' ) ' || tname;
		if counter > 1 then
			from_clause := from_clause || ' ON ' || oldtname || '.id=' || tname || '.parent_ms_id ';
		END IF;

		oldtname := tname;
		counter := counter + 1;
	end loop;

	--raise notice 'myquery:     %', myquery;
	--raise notice 'product:     %', product;
	--raise notice 'from_clause: %', from_clause;

	-- test
	-- select eqged.make_ms_query(false);

	myquery := myquery || product || ' AS ms_value' || from_clause;
	RETURN myquery;
END;
$$;

COMMENT ON FUNCTION eqged.make_ms_query() IS
'Generate the query string to select a table with the flattened mapping scheme structure. Internal function used by eqged.make_joined().';

CREATE OR REPLACE FUNCTION eqged.rebuild_gadm_country_population() RETURNS void
LANGUAGE plpgsql AS
$$
BEGIN
  TRUNCATE TABLE eqged.gadm_country_population;
  ALTER SEQUENCE eqged.gadm_country_population_id_seq RESTART WITH 1;
  INSERT INTO eqged.gadm_country_population(gadm_country_id, population_src_id, pop_value, pop_count)
    SELECT a.gadm_country_id, b.population_src_id, SUM(b.pop_value), COUNT(b.pop_value)
      FROM eqged.grid_point_country a RIGHT JOIN eqged.population b USING (grid_point_id)
      GROUP BY a.gadm_country_id, b.population_src_id;
END;
$$;

COMMENT ON FUNCTION eqged.rebuild_gadm_country_population() IS
'Truncates and rebuilds the contents of eqged.gadm_country_population, for all GADM countries and all population sources. This function assumes that no rows with pop_value=0 exists in eqged.population.';

CREATE OR REPLACE FUNCTION eqged.rebuild_ged() RETURNS void
LANGUAGE plpgsql AS
$$
declare
	study_region_record RECORD;
begin	

	-- process all study regions for initial GED
	for study_region_record  in 
		select id from eqged.study_regions where id in 
		(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,91,92,93,94,95,96,97,98,99,100,101,102,103,104,105,106,107,108,109,110,111,112,113,114,115,116,117,118,119,120,121,122,123,124,125,126,127,128,129,130,131,132,133,134,135,136,137,138,139,140,141,142,143,144,145,146,147,148,149,150,151,152,153,154,155,156,157,158,159,160,161,162,163,164,165,166,167,168,169,170,171,172,173,174,175,176,177,178,179,180,181,182,183,184,185,186,187,188,189,190,191,192,193,194,195,196,197,198,199,200,201,202,203,204,205,206,207,208,209,210,211,212,213,214,215,216,217,218,219,220,221,222,223,224,225,226,227,228,229,230,231,232,233,234,235,236,237,238,239,240,241,242,243,244,245,246)
	loop
		select eqged.fill_agg_build_infra(1, True);
	end loop;
end;
$$;

COMMENT ON FUNCTION eqged.rebuild_ged() IS
'Rebuild exposure for all study regions.'

CREATE OR REPLACE FUNCTION eqged.rebuild_grid_point_admin_1() RETURNS void
LANGUAGE plpgsql AS
$$
DECLARE
  gadm_admin_1_record RECORD;
  total INTEGER;
  counter INTEGER;
BEGIN
  RAISE NOTICE 'Dropping constraints';
  ALTER TABLE eqged.grid_point_admin_1 DROP CONSTRAINT grid_point_admin_1_pkey;
  ALTER TABLE eqged.grid_point_admin_1 DROP CONSTRAINT eqged_grid_point_admin_1_gadm_admin_1_fk;
  ALTER TABLE eqged.grid_point_admin_1 DROP CONSTRAINT eqged_grid_point_admin_1_grid_point_fk;

  counter := 0;
  SELECT INTO total COUNT(*) FROM eqged.gadm_admin_1;
  FOR gadm_admin_1_record IN
    SELECT id, name FROM eqged.gadm_admin_1
  LOOP
    counter := counter + 1;
    RAISE NOTICE 'Processing % - % (%/%)', gadm_admin_1_record.id, gadm_admin_1_record.name, counter, total;
    PERFORM eqged.build_gadm_admin_1(gadm_admin_1_record.id);
  END LOOP;
  RAISE NOTICE 'Rebuilding constraints';
  ALTER TABLE eqged.grid_point_admin_1
    ADD CONSTRAINT grid_point_admin_1_pkey PRIMARY KEY(grid_point_id , gadm_admin_1_id );
  ALTER TABLE eqged.grid_point_admin_1
    ADD CONSTRAINT eqged_grid_point_admin_1_gadm_admin_1_fk FOREIGN KEY (gadm_admin_1_id)
      REFERENCES eqged.gadm_admin_1 (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION;
  ALTER TABLE eqged.grid_point_admin_1
    ADD CONSTRAINT eqged_grid_point_admin_1_grid_point_fk FOREIGN KEY (grid_point_id)
      REFERENCES eqged.grid_point (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION;
  RAISE NOTICE 'All done - remember to VACUUM ANALYZE the table!';
END;
$$;

COMMENT ON FUNCTION eqged.rebuild_grid_point_admin_1() IS
'Truncates and rebuilds eqged.grid_point_admin_1, for all grid points and GADM regions.';

CREATE OR REPLACE FUNCTION eqged.rebuild_grid_point_admin_2() RETURNS void
LANGUAGE plpgsql AS
$$
DECLARE
  gadm_admin_2_record RECORD;
  total INTEGER;
  counter INTEGER;
BEGIN
  RAISE NOTICE 'Dropping constraints';
  ALTER TABLE eqged.grid_point_admin_2 DROP CONSTRAINT grid_point_admin_2_pkey;
  ALTER TABLE eqged.grid_point_admin_2 DROP CONSTRAINT eqged_grid_point_admin_2_gadm_admin_2_fk;
  ALTER TABLE eqged.grid_point_admin_2 DROP CONSTRAINT eqged_grid_point_admin_2_grid_point_fk;

  counter := 0;
  SELECT INTO total COUNT(*) FROM eqged.gadm_admin_2;
  FOR gadm_admin_2_record IN
    SELECT id, name FROM eqged.gadm_admin_2
  LOOP
    counter := counter + 1;
    RAISE NOTICE 'Processing % - % (%/%)', gadm_admin_2_record.id, gadm_admin_2_record.name, counter, total;
    PERFORM eqged.build_gadm_admin_2(gadm_admin_2_record.id);
  END LOOP;
  RAISE NOTICE 'Rebuilding constraints';
  ALTER TABLE eqged.grid_point_admin_2
    ADD CONSTRAINT grid_point_admin_2_pkey PRIMARY KEY(grid_point_id , gadm_admin_2_id );
  ALTER TABLE eqged.grid_point_admin_2
    ADD CONSTRAINT eqged_grid_point_admin_2_gadm_admin_2_fk FOREIGN KEY (gadm_admin_2_id)
      REFERENCES eqged.gadm_admin_2 (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION;
  ALTER TABLE eqged.grid_point_admin_2
    ADD CONSTRAINT eqged_grid_point_admin_2_grid_point_fk FOREIGN KEY (grid_point_id)
      REFERENCES eqged.grid_point (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION;
  RAISE NOTICE 'All done - remember to VACUUM ANALYZE the table!';
END;
$$;

COMMENT ON FUNCTION eqged.rebuild_grid_point_admin_2() IS
'Truncates and rebuilds eqged.grid_point_admin_2, for all grid points and GADM regions.';

CREATE OR REPLACE FUNCTION eqged.rebuild_grid_point_country() RETURNS void
LANGUAGE plpgsql AS
$$
DECLARE
  gadm_country_record RECORD;
  total INTEGER;
  counter INTEGER;
BEGIN
  RAISE NOTICE 'Dropping constraints';
  ALTER TABLE eqged.grid_point_country DROP CONSTRAINT grid_point_country_pkey;
  ALTER TABLE eqged.grid_point_country DROP CONSTRAINT eqged_grid_point_country_gadm_country_fk;
  ALTER TABLE eqged.grid_point_country DROP CONSTRAINT eqged_grid_point_country_grid_point_fk;

  counter := 0;
  SELECT INTO total COUNT(*) FROM eqged.gadm_country;
  FOR gadm_country_record IN
    SELECT id, name FROM eqged.gadm_country
  LOOP
    counter := counter + 1;
    RAISE NOTICE 'Processing % - % (%/%)', gadm_country_record.id, gadm_country_record.name, counter, total;
    PERFORM eqged.build_gadm_country(gadm_country_record.id);
  END LOOP;
  RAISE NOTICE 'Rebuilding constraints';
  ALTER TABLE eqged.grid_point_country
    ADD CONSTRAINT grid_point_country_pkey PRIMARY KEY(grid_point_id , gadm_country_id );
  ALTER TABLE eqged.grid_point_country
    ADD CONSTRAINT eqged_grid_point_country_gadm_country_fk FOREIGN KEY (gadm_country_id)
      REFERENCES eqged.gadm_country (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION;
  ALTER TABLE eqged.grid_point_country
    ADD CONSTRAINT eqged_grid_point_country_grid_point_fk FOREIGN KEY (grid_point_id)
      REFERENCES eqged.grid_point (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION;
  RAISE NOTICE 'All done - remember to VACUUM ANALYZE the table!';
END;
$$;

COMMENT ON FUNCTION eqged.rebuild_grid_point_country() IS
'Truncates and rebuilds eqged.grid_point_country, for all grid points and GADM regions.';

CREATE OR REPLACE FUNCTION refresh_last_update() RETURNS TRIGGER
LANGUAGE plpgsql AS
$$
DECLARE
BEGIN
    NEW.last_update := timezone('UTC'::text, now());
    RETURN NEW;
END;
$$;

COMMENT ON FUNCTION refresh_last_update() IS
'Refresh the ''last_update'' time stamp whenever a row is updated.';
