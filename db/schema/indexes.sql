/*
  Indexes for the OpenQuake database.

    Copyright (c) 2010-2011, GEM Foundation.

    OpenQuake is free software: you can redistribute it and/or modify
    it under the terms of the GNU Lesser General Public License version 3
    only, as published by the Free Software Foundation.

    OpenQuake is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Lesser General Public License version 3 for more details
   a copy is included in the LICENSE file that accompanied this code).

    You should have received a copy of the GNU Lesser General Public License
    version 3 along with OpenQuake.  If not, see
    <http://www.gnu.org/licenses/lgpl-3.0.txt> for a copy of the LGPLv3 License.
*/

-- admin.oq_user
CREATE UNIQUE INDEX admin_oq_user_user_name_uniq_idx ON admin.oq_user(user_name);

-- admin.revision_info
CREATE UNIQUE INDEX admin_revision_info_artefact_uniq_idx ON admin.revision_info(artefact);

-- eqcat.catalog
CREATE INDEX eqcat_catalog_agency_idx on eqcat.catalog(agency);
CREATE INDEX eqcat_catalog_time_idx on eqcat.catalog(time);
CREATE INDEX eqcat_catalog_depth_idx on eqcat.catalog(depth);
CREATE INDEX eqcat_catalog_point_idx ON eqcat.catalog USING gist(point);

-- eqged geometry indexes
CREATE INDEX eqged_agg_build_infra_src_the_geom_idx ON eqged.agg_build_infra_src USING gist(the_geom);
CREATE INDEX eqged_grid_point_the_geom_idx ON eqged.grid_point USING gist(the_geom);
CREATE INDEX eqged_gadm_country_the_geom_idx ON eqged.gadm_admin_1 USING gist(the_geom);
CREATE INDEX eqged_gadm_country_the_geom_idx ON eqged.gadm_admin_2 USING gist(the_geom);
CREATE INDEX eqged_gadm_country_the_geom_idx ON eqged.gadm_country USING gist(the_geom);

-- eqged indexes for foreign keys
CREATE INDEX eqged_agg_build_infra_agg_build_infra_src_id_idx ON eqged.agg_build_infra(agg_build_infra_src_id);
CREATE INDEX eqged_agg_build_infra_grid_point_id_idx ON eqged.agg_build_infra(grid_point_id);
CREATE INDEX eqged_agg_build_infra_pop_agg_build_infra_id_idx ON eqged.agg_build_infra_pop(agg_build_infra_id);
CREATE INDEX eqged_agg_build_infra_pop_country_id_idx ON eqged.agg_build_infra_pop(country_id);
CREATE INDEX eqged_agg_build_infra_pop_grid_point_id_idx ON eqged.agg_build_infra_pop(grid_point_id);
CREATE INDEX eqged_agg_build_infra_pop_population_src_id_idx ON eqged.agg_build_infra_pop(population_src_id);
CREATE INDEX eqged_agg_build_infra_pop_ratio_agg_build_infra_id_idx ON eqged.agg_build_infra_pop_ratio(agg_build_infra_id);
CREATE INDEX eqged_agg_build_infra_pop_ratio_country_id_idx ON eqged.agg_build_infra_pop_ratio(country_id);
CREATE INDEX eqged_agg_build_infra_pop_ratio_grid_point_id_idx ON eqged.agg_build_infra_pop_ratio(grid_point_id);
CREATE INDEX eqged_agg_build_infra_src_mapping_scheme_src_id_idx ON eqged.agg_build_infra_src(mapping_scheme_src_id);
CREATE INDEX eqged_agg_build_infra_src_study_region_id_idx ON eqged.agg_build_infra_src(study_region_id);
CREATE INDEX eqged_cresta_country_country_id_idx ON eqged.cresta_country(country_id);
CREATE INDEX eqged_cresta_zone_country_id_idx ON eqged.cresta_zone(country_id);
CREATE INDEX eqged_grid_point_admin_1_admin_1_id ON eqged.grid_point_admin_1(admin_1_id);
CREATE INDEX eqged_grid_point_admin_1_grid_point_id ON eqged.grid_point_admin_1(grid_point_id);
CREATE INDEX eqged_grid_point_admin_2_admin_1_id ON eqged.grid_point_admin_2(admin_2_id);
CREATE INDEX eqged_grid_point_admin_2_grid_point_id ON eqged.grid_point_admin_2(grid_point_id);
CREATE INDEX eqged_grid_point_admin_3_admin_1_id ON eqged.grid_point_admin_3(admin_3_id);
CREATE INDEX eqged_grid_point_admin_3_grid_point_id ON eqged.grid_point_admin_3(grid_point_id);
CREATE INDEX eqged_grid_point_country_admin_1_id ON eqged.grid_point_country(country_id);
CREATE INDEX eqged_grid_point_country_grid_point_id ON eqged.grid_point_country(grid_point_id);
CREATE INDEX eqged_grid_point_cresta_zone_idx ON eqged.grid_point(cresta_zone);
CREATE INDEX eqged_grid_point_cresta_subzone_idx ON eqged.grid_point(cresta_subzone);
CREATE INDEX eqged_grid_point_organization_id_idx ON eqged.grid_point(organization_id);
CREATE INDEX eqged_mapping_scheme_mapping_scheme_src_id_idx ON eqged.mapping_scheme(mapping_scheme_src_id);
CREATE INDEX eqged_mapping_scheme_ms_class_id_idx ON eqged.mapping_scheme(ms_class_id);
CREATE INDEX eqged_mapping_scheme_parent_ms_id_idx ON eqged.mapping_scheme(parent_ms_id);
CREATE INDEX eqged_mapping_scheme_class_ms_type_id_idx ON eqged.mapping_scheme(ms_type_id);
CREATE INDEX eqged_mapping_scheme_src_oq_user_id_idx ON eqged.mapping_scheme_src(oq_user_id);
CREATE INDEX eqged_population_grid_point_id_idx ON eqged.population(grid_point_id);
CREATE INDEX eqged_population_population_src_id_idx ON eqged.population(population_src_id);
CREATE INDEX eqged_pop_allocation_country_id_idx ON eqged.pop_allocation(country_id);
CREATE INDEX eqged_study_region_oq_user_id_idx ON eqged.study_region(oq_user_id);

-- pshai.fault_edge
CREATE INDEX pshai_fault_edge_bottom_idx ON pshai.fault_edge USING gist(bottom);
CREATE INDEX pshai_fault_edge_top_idx ON pshai.fault_edge USING gist(top);

-- pshai.rupture
CREATE INDEX pshai_rupture_point_idx ON pshai.rupture USING gist(point);

-- pshai.simple_fault
CREATE INDEX pshai_simple_fault_edge_idx ON pshai.simple_fault USING gist(edge);

-- pshai.source
CREATE INDEX pshai_source_area_idx ON pshai.source USING gist(area);
CREATE INDEX pshai_source_point_idx ON pshai.source USING gist(point);

-- index for the 'owner_id' foreign key
CREATE INDEX eqcat_catalog_owner_id_idx on eqcat.catalog(owner_id);
CREATE INDEX pshai_complex_fault_owner_id_idx on pshai.complex_fault(owner_id);
CREATE INDEX pshai_fault_edge_owner_id_idx on pshai.fault_edge(owner_id);
CREATE INDEX pshai_focal_mechanism_owner_id_idx on pshai.focal_mechanism(owner_id);
CREATE INDEX pshai_mfd_evd_owner_id_idx on pshai.mfd_evd(owner_id);
CREATE INDEX pshai_mfd_tgr_owner_id_idx on pshai.mfd_tgr(owner_id);
CREATE INDEX pshai_r_depth_distr_owner_id_idx on pshai.r_depth_distr(owner_id);
CREATE INDEX pshai_r_rate_mdl_owner_id_idx on pshai.r_rate_mdl(owner_id);
CREATE INDEX pshai_rupture_owner_id_idx on pshai.rupture(owner_id);
CREATE INDEX pshai_simple_fault_owner_id_idx on pshai.simple_fault(owner_id);
CREATE INDEX pshai_source_owner_id_idx on pshai.source(owner_id);

CREATE INDEX uiapi_input_owner_id_idx on uiapi.input(owner_id);
CREATE INDEX uiapi_oq_job_owner_id_idx on uiapi.oq_job(owner_id);
CREATE INDEX uiapi_output_owner_id_idx on uiapi.output(owner_id);
CREATE INDEX uiapi_upload_owner_id_idx on uiapi.upload(owner_id);

-- uiapi indexes on foreign keys
CREATE INDEX uiapi_hazard_map_data_output_id_idx on uiapi.hazard_map_data(output_id);
CREATE INDEX uiapi_oq_params_upload_id_idx on uiapi.oq_params(upload_id);
CREATE INDEX uiapi_loss_map_data_output_id_idx on uiapi.loss_map_data(output_id);
