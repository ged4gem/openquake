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

CREATE OR REPLACE FUNCTION eqged.fill_agg_build_infra(study_region_id numeric, population_src_id numeric) RETURNS void
LANGUAGE plpgsql AS
$$
declare
    mapping_scheme_record RECORD;
    counter integer;
begin	
--
-- script for applying mapping scheme for creating GED level1 database
--
-- population data tables
-- eqged.grid_points: id and geometry 
-- eqged.grid_point_attribute: urban condition flag,
-- eqged.grid_point_country: gadm_country_id
-- eqged.population/eqged.population_src: actual population for grid cell
-- eqged.pop_allocation: ratio of population for different conditions (urban, time of day, occupancy)
--
-- mapping scheme tables
-- eqged.mapping_scheme_src, eqged.mapping_scheme, eqged.mapping_scheme_types, eqged.mapping_scheme_classes:
-- 	contain entire mapping scheme tree
-- 	these tables are combined into eqged.foo, eqged.foo has the correct format 
-- 
-- link tables
-- study_regions: each study region contains multiple mapping schemes that can be applied to different
-- 	sub-regions 
-- agg_build_infra_src: establish the links between population data and mapping schemes

        -- populate agg_build_infra
        
	for mapping_scheme_record in 
		select id, study_region_id, mapping_scheme_src_id, gadm_country_id, 
		       gadm_admin_1_id, gadm_admin_2_id, the_geom
		       from eqged.agg_build_infra_src 
		where study_region_id = study_region_id
	loop
	        raise notice 'process agg_build_infra_src %', mapping_scheme_record.id;

		counter := 0;
		for mapping_scheme_record_2 in
			select *
			from eqged.foo
			where mapping_scheme_src_id = mapping_scheme_record.mapping_scheme_src_id;
		loop
			counter := counter + 1;
			raise notice 'process mapping scheme % (counter is %)', mapping_scheme_record.mapping_scheme_src_id, counter;
			-- structure
			insert into eqged.agg_build_infra (agg_build_infra_src_id, ms_class_group_id, ms_class_id)
			values (mapping_scheme_record.id, counter, case when t4_ms_class_id is null then t3_ms_class_id else t4_ms_class_id);

			-- height
			insert into eqged.agg_build_infra (agg_build_infra_src_id, ms_class_group_id, ms_class_id)
			values (mapping_scheme_record.id, counter, t4_ms_class_id);

			-- age (not implemented, use dummy value)
			insert into eqged.agg_build_infra (agg_build_infra_src_id, ms_class_group_id, ms_class_id)
			values (mapping_scheme_record.id, counter, 0);

			-- occupancy
			insert into eqged.agg_build_infra (agg_build_infra_src_id, ms_class_group_id, ms_class_id)
			select mapping_scheme_record.id as agg_build_infra_src_id,
			       counter as ms_class_group_id,
			       ms_class_id as ms_class_id
			from eqged.mapping_scheme_class c
			where c.ms_type_id = 5 and ms_type_class_id = 1
			
			insert into eqged.agg_build_infra (agg_build_infra_src_id, ms_class_group_id, ms_class_id)
			select mapping_scheme_record.id as agg_build_infra_src_id,
			       counter as ms_class_group_id,
			       ms_class_id as ms_class_id
			from eqged.mapping_scheme_class c
			where c.ms_type_id = 5 and ms_type_class_id = 2
		end loop;
	
		if (mapping_scheme_record.gadm_country_id is not null) then
			if (mapping_scheme_record.gadm_admin_1_id is not null) then
				if (mapping_scheme_record.gadm_admin_2_id is not null) then
					raise notice '  using GADM admin2 region %', mapping_scheme_record.gadm_admin_2_id;
					insert into agg_build_infra_pop_ratio (agg_build_infra_id, gadm_country_id, grid_point_id, day_pop_ratio, night_pop_ratio, transit_pop_ratio)
					select eqged.agg_build_infra.id, mapping_scheme_record.gadm_country_id, a.grid_point_id,
					  ms.ms_value * p.day_pop_ratio, ms.ms_value * p.night_pop_ratio, 
					  ms.ms_value * p.transit_pop_ratio
					from eqged.agg_build_infra agg, eqged.pop_allocation p, eqged.foo ms, 
					eqged.mapping_scheme_class mapping_scheme_class,
					(
					  select a.grid_point_id as grid_point_id, a.is_urban
					  from eqged.grid_point_admin_2 c, eqged.grid_point_attribute a
					  where c.gadm_admin_2_id = mapping_scheme_record.gadm_admin_2_id and
					  a.grid_point_id = c.grid_point_id
					) g,
					(
					  select ms_type_class_id as id
					  from eqged.mapping_scheme_class c
					  where c.ms_type_id = 5
					) occ,
					where agg.agg_build_infra_src_id = mapping_scheme_record.id and
					      agg.ms_class_group_id = ms.row_id and
					      ms.mapping_scheme_src_id = mapping_scheme_record.mapping_scheme_src_id and
					      p.gadm_country_id = mapping_scheme_record.gadm_country_id and
					      p.is_urban = g.is_urban and p.occupancy_id = occ.id;					
						end if;
				else
					raise notice '  using GADM admin1 region %', mapping_scheme_record.gadm_admin_1_id;
					insert into agg_build_infra_pop_ratio (agg_build_infra_id, gadm_country_id, grid_point_id, day_pop_ratio, night_pop_ratio, transit_pop_ratio)
					select eqged.agg_build_infra.id, mapping_scheme_record.gadm_country_id, a.grid_point_id,
					  ms.ms_value * p.day_pop_ratio, ms.ms_value * p.night_pop_ratio, 
					  ms.ms_value * p.transit_pop_ratio
					from eqged.agg_build_infra agg, eqged.pop_allocation p, eqged.foo ms, 
					eqged.mapping_scheme_class mapping_scheme_class,
					(
					  select a.grid_point_id as grid_point_id, a.is_urban
					  from eqged.grid_point_admin_1 c, eqged.grid_point_attribute a
					  where c.gadm_admin_1_id = mapping_scheme_record.gadm_admin_1_id and
					  a.grid_point_id = c.grid_point_id
					) g,
					(
					  select ms_type_class_id as id
					  from eqged.mapping_scheme_class c
					  where c.ms_type_id = 5
					) occ,
					where agg.agg_build_infra_src_id = mapping_scheme_record.id and
					      agg.ms_class_group_id = ms.row_id and
					      ms.mapping_scheme_src_id = mapping_scheme_record.mapping_scheme_src_id and
					      p.gadm_country_id = mapping_scheme_record.gadm_country_id and
					      p.is_urban = g.is_urban and p.occupancy_id = occ.id;					
						end if;
			else
				raise notice '  using GADM country region %', mapping_scheme_record.gadm_country_id;
			end if;
			
			insert into agg_build_infra_pop_ratio (agg_build_infra_id, gadm_country_id, grid_point_id, day_pop_ratio, night_pop_ratio, transit_pop_ratio)
			select eqged.agg_build_infra.id, mapping_scheme_record.gadm_country_id, a.grid_point_id,
			  ms.ms_value * p.day_pop_ratio, ms.ms_value * p.night_pop_ratio, 
			  ms.ms_value * p.transit_pop_ratio
			from eqged.agg_build_infra agg, eqged.pop_allocation p, eqged.foo ms, 
			eqged.mapping_scheme_class mapping_scheme_class,
			(
			  select a.grid_point_id as grid_point_id, a.is_urban
			  from eqged.grid_point_country c, eqged.grid_point_attribute a
			  where c.gadm_country_id = mapping_scheme_record.gadm_country_id and
			  a.grid_point_id = c.grid_point_id
			) g,
			(
			  select ms_type_class_id as id
			  from eqged.mapping_scheme_class c
			  where c.ms_type_id = 5
			) occ,
			where agg.agg_build_infra_src_id = mapping_scheme_record.id and
			      agg.ms_class_group_id = ms.row_id and
			      ms.mapping_scheme_src_id = mapping_scheme_record.mapping_scheme_src_id and
			      p.gadm_country_id = mapping_scheme_record.gadm_country_id and
			      p.is_urban = g.is_urban and p.occupancy_id = occ.id;
		else
			raise notice '  using point in polygon (not implemented)';
			insert into agg_build_infra_pop_ratio (agg_build_infra_id, gadm_country_id, grid_point_id, day_pop_ratio, night_pop_ratio, transit_pop_ratio)
			select eqged.agg_build_infra.id, mapping_scheme_record.gadm_country_id, a.grid_point_id,
			  ms.ms_value * p.day_pop_ratio, ms.ms_value * p.night_pop_ratio, 
			  ms.ms_value * p.transit_pop_ratio
			from eqged.agg_build_infra agg, eqged.pop_allocation p, eqged.foo ms, 
			eqged.mapping_scheme_class mapping_scheme_class,
			(
			  select a.grid_point_id as grid_point_id, a.is_urban
			  from eqged.grid_point g, eqged.grid_point_attribute a
			  where st_contains(mapping_scheme_record.the_geom, g.the_geom) and
			  a.grid_point_id = c.grid_point_id
			) g,
			(
			  select ms_type_class_id as id
			  from eqged.mapping_scheme_class c
			  where c.ms_type_id = 5
			) occ,
			where agg.agg_build_infra_src_id = mapping_scheme_record.id and
			      agg.ms_class_group_id = ms.row_id and
			      ms.mapping_scheme_src_id = mapping_scheme_record.mapping_scheme_src_id and
			      p.gadm_country_id = mapping_scheme_record.gadm_country_id and
			      p.is_urban = g.is_urban and p.occupancy_id = occ.id;			
		end if;
		
		insert into eqged.agg_build_infra_pop (agg_build_infra_pop_ratio_id, population_id, day_pop, night_pop, transit_pop)
		select pop_ratio.id, pop.id, pop_ratio.day_pop_ratio * pop.pop_value, pop_ratio.day_pop_ratio * pop.night_value, 
		       pop_ratio.transit_pop_ratio * pop.pop_value
		from eqged.agg_build_infra agg, eqged.agg_build_infra_pop_ratio pop_ratio, eqged.population pop
		where pop_ratio.grid_point_id = pop.grid_point_id and pop.population_src_id = population_src_id
		and agg.agg_build_infra_src_id = mapping_scheme_record.id and pop_ratio.agg_build_infra_id = agg.id;		
	end loop;
end;
$$;

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
  drop table if exists eqged.foo;
  create temporary table eqged_temp_mapping_scheme as select * from eqged.view_mapping_scheme;

  innerquery := eqged.make_ms_query(true);
  myquery := 'create table eqged.foo as SELECT u1.* ';
  from_clause := ' FROM (' || innerquery || ') u1 ';
  
  select count(*) from (select parent_ms_type_id, ms_type_id from eqged_temp_mapping_scheme 
    group by parent_ms_type_id, ms_type_id 
    order by parent_ms_type_id, ms_type_id) t into tabcount;
  for counter in 1 .. tabcount loop
    tabname := 't' || counter;
    typetabname := 'u' || (counter + 10);

    myquery := myquery || ', ' || typetabname || '.name as t' || counter || '_type_name';
    from_clause := from_clause || ' LEFT JOIN eqged.mapping_scheme_types ' || typetabname || ' on u1.t' || counter || '_ms_type_id=' || typetabname || '.id ';
    
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

CREATE OR REPLACE FUNCTION eqged.make_ms_query(use_temp_table boolean) RETURNS text
LANGUAGE plpgsql AS
$$
DECLARE
        my_parent_type integer;
        my_type integer;
        counter integer := 1;
        myrow RECORD;
        myquery text := 'SELECT t1.mapping_scheme_src_id, row_number() over (partition by mapping_scheme_src_id) row_id,';
        tname char(2);
        oldtname char(2);
        from_clause text := ' FROM ';
        product text := '';
        ms_table text;
BEGIN
  if use_temp_table THEN
	ms_table := 'eqged_temp_mapping_scheme';
  ELSE
	ms_table := 'eqged.view_mapping_scheme';
  END IF;

  for myrow in execute
    'select ms_type_id from ' || ms_table || ' group by ms_type_id order by ms_type_id'
  loop
     my_type := myrow.ms_type_id;
     tname := 't' || counter; -- table identifier (e.g. t1)
     myquery := myquery || tname || '.ms_type_id AS ' || tname || '_ms_type_id, ' || tname || '.ms_type_class_id AS ' || tname || '_ms_type_class_id, ' || tname || '.ms_name AS ' || tname || '_ms_name, ' || ' CASE WHEN ' || tname || '.ms_value IS NULL THEN 1 ELSE ' || tname || '.ms_value END AS ' || tname || '_ms_value, ';
     
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
  
  myquery := myquery || product || ' AS ms_value' || from_clause;
  
  RETURN myquery;
END;
$$;

COMMENT ON FUNCTION eqged.make_ms_query() IS
'Generate the query string to select a table with the flattened mapping scheme structure.';

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
