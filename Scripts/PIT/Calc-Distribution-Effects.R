'Distribution tables'
# I.FUNCTIONS ---------------------------------------------------------------

        # Function to extract columns and add scenario
        extract_centile_rev_fun <- function(dt, scenario) {
          dt[, .(centile_group,pitax,g_total_gross, scenario = scenario)]
        }

        # Function to extract columns and add scenario
        extract_dec_rev_fun <- function(dt, scenario) {
          dt[, .(decile_group,pitax,g_total_gross, scenario = scenario)]
        }

        # Function to extract columns and add scenario
        extract_bins_rev_fun <- function(dt, scenario) {
          dt[, .(id_n,weight,g_total_gross,pitax, scenario = scenario)]
        }
        
# II.ESTIMATIONS OF PERCENTILE AND DECILE ---------------------------------
      # 1.Centile Groups ---------------------------------------------------------
          # 1.1 BU --------------------------------------------------------------------
                       extracted_dist_tables_bu <- mapply(extract_centile_rev_fun, PIT_BU_list, scenarios, SIMPLIFY = FALSE)
                        combined_dt <- rbindlist(extracted_dist_tables_bu)
                        
                        
                        combined_dt[, year := forecast_horizon[match(scenario, scenarios)]]
                        
                        combined_dt<-combined_dt%>%
                          filter(year==simulation_year)
                        
                        
                        # # # Convert your dataset to a data.table
                         combined_dt <- as.data.table(combined_dt)
      
                        # Perform the required operations
                        pit_centile_distribution_bu <- combined_dt[, .(
                                                                            sum_calc_pitax = sum(pitax, na.rm = TRUE),
                                                                            sum_total_gross_income = sum(g_total_gross, na.rm = TRUE)
                                                                          ), by = .(scenario, centile_group)]
      
                        # Calculate ETR
                        pit_centile_distribution_bu[, etr := sum_calc_pitax / sum_total_gross_income]
                        pit_centile_distribution_bu[, year := forecast_horizon[match(scenario, scenarios)]]
                        setorder(pit_centile_distribution_bu, centile_group)
                  
                        
          # 1.2 SIM -------------------------------------------------------------------
                        extracted_dist_tables_sim <- mapply(extract_centile_rev_fun, PIT_SIM_list, scenarios, SIMPLIFY = FALSE)
                        combined_dt <- rbindlist(extracted_dist_tables_sim)
                       
                        combined_dt[, year := forecast_horizon[match(scenario, scenarios)]]
                        combined_dt<-combined_dt%>%
                          filter(year==simulation_year)
                        
                        
                        
                        combined_dt <- as.data.table(combined_dt)
      
                        pit_centile_distribution_sim <- combined_dt[, .(
                          sum_calc_pitax = sum(pitax, na.rm = TRUE),
                          sum_total_gross_income = sum(g_total_gross, na.rm = TRUE)
                        ), by = .(scenario, centile_group)]
      
                        # Calculate ETR
                        pit_centile_distribution_sim[, etr := sum_calc_pitax / sum_total_gross_income]
                        pit_centile_distribution_sim[, year := forecast_horizon[match(scenario, scenarios)]]
                        setorder(pit_centile_distribution_sim, centile_group)
                        
                     
      
          # 1.3 MERGE BU AND SIM -----------------------------------------------------------------
                        setkey(pit_centile_distribution_bu, centile_group, scenario, year)
                        setkey(pit_centile_distribution_sim, centile_group, scenario, year)
                        
                        pit_centile_distribution_bu_sim <- merge(pit_centile_distribution_bu, pit_centile_distribution_sim, by = c("centile_group", "scenario", "year"), suffixes = c("_bu", "_sim"))
                        setorder(pit_centile_distribution_bu_sim, centile_group)
      
          # 1.3 Chart -------------------------------------------------------------------
                      # pit_centile_distribution_bu_sub<-pit_centile_distribution_bu_sim%>%
                      #                               filter(year==simulation_year)
                      # 
            
      # 2.Decile Groups ---------------------------------------------------------
          # 1.BU --------------------------------------------------------------------
                       extracted_dist_tables_bu <- mapply(extract_dec_rev_fun, PIT_BU_list, scenarios, SIMPLIFY = FALSE)
                        combined_dt <- rbindlist(extracted_dist_tables_bu)
                       
                        combined_dt[, year := forecast_horizon[match(scenario, scenarios)]]
                        
                        combined_dt<-combined_dt%>%
                          filter(year==simulation_year)
                   
                        
                        pit_decile_distribution_bu <- combined_dt[, .(
                                        sum_calc_pitax = sum(pitax, na.rm = TRUE),
                                        mean_calc_pitax = mean(pitax, na.rm = TRUE),
                                        sum_total_gross_income = sum(g_total_gross, na.rm = TRUE)
                        ), by = .(scenario, decile_group)]
                        
                     
                        pit_decile_distribution_bu[, year := forecast_horizon[match(scenario, scenarios)]]
                        
                        
                        setorder(pit_decile_distribution_bu, decile_group )
                        
          # 2.SIM -------------------------------------------------------------------
                        extracted_dist_tables_sim <- mapply(extract_dec_rev_fun, PIT_SIM_list, scenarios, SIMPLIFY = FALSE)
                        combined_dt <- rbindlist(extracted_dist_tables_sim)
                      
                        combined_dt[, year := forecast_horizon[match(scenario, scenarios)]]
                        
                        combined_dt<-combined_dt%>%
                          filter(year==simulation_year)
                        
                        
                        
                        
                        #setorder(combined_dt, decile_group)
                        
                        pit_decile_distribution_sim <- combined_dt[, .(
                                                      sum_calc_pitax = sum(pitax, na.rm = TRUE),
                                                      mean_calc_pitax = mean(pitax, na.rm = TRUE),
                                                      sum_total_gross_income = sum(g_total_gross, na.rm = TRUE)
                                                    ), by = .(scenario, decile_group)]
                        
                        # Calculate ETR
                        #pit_decile_distribution_sim[, etr := sum_calc_pitax / sum_total_gross_income]
                        
                        pit_decile_distribution_sim[, year := forecast_horizon[match(scenario, scenarios)]]
                        
                        
                        setorder(pit_decile_distribution_sim, decile_group )
                        
                        
          # 3.MERGE BU AND SIM -----------------------------------------------------------------
                        setkey(pit_decile_distribution_bu, decile_group, scenario, year)
                        setkey(pit_decile_distribution_sim, decile_group, scenario, year)
                        pit_decile_distribution_bu_sim_raw <- merge(pit_decile_distribution_bu, pit_decile_distribution_sim, by = c("decile_group", "scenario", "year"), suffixes = c("_bu", "_sim"))
                        
                        pit_decile_distribution_bu_sim<-pit_decile_distribution_bu_sim_raw
      
                        pit_decile_distribution_bu_sim$year<-as.character(pit_decile_distribution_bu_sim$year)
                        pit_decile_distribution_bu_sim$decile_group<-as.character(pit_decile_distribution_bu_sim$decile_group)
                        
                        pit_decile_distribution_bu_sim<-setnames(pit_decile_distribution_bu_sim,
                                 old = c('decile_group','sum_calc_pitax_bu', 'mean_calc_pitax_bu', 'sum_total_gross_income_bu','sum_calc_pitax_sim', 'mean_calc_pitax_sim', 'sum_total_gross_income_sim'),
                                 new = c( 'Decile groups', 'Total PIT liability (business as usual)', 'Average PIT liability (business as usual)', 'Total gross income (business as usual)',
                                         'Total PIT liability (simulation)', 'Average PIT liability (simulation)', 'Total gross income (simulation)'
                                 ))
      
      
                        
      
                       
                        # pit_decile_distribution_bu_sim <- pit_decile_distribution_bu_sim %>%
                        #   mutate_if(is.numeric, ~ round(. / 1e06, 1))
      
                        
                        pit_decile_distribution_bu_sim <- pit_decile_distribution_bu_sim %>%
                          mutate(across(
                            .cols = where(is.numeric) & !starts_with("Average PIT liability (business as usual)") & 
                              !starts_with("Average PIT liability (simulation)"),
                            .fns = ~ round(. / 1e06, 1)
                          )) %>%
                          mutate(across(
                            .cols = where(is.numeric) & (starts_with("Average PIT liability (business as usual)") | 
                                                           starts_with("Average PIT liability (simulation)")),
                            .fns = ~ round(. / 1000, 1)
                          ))
                        
                        
                        setorder(pit_decile_distribution_bu_sim, year)
                        
                        pit_decile_distribution_bu_sim<-pit_decile_distribution_bu_sim%>%
                          filter(year==SimulationYear)
      
                        pit_decile_distribution_bu_sim$scenario<-NULL
                        pit_decile_distribution_bu_sim$year<-NULL
                        
      # 3. Chart -------------------------------------------------------------------
                      # pit_decile_distribution_bu_sub<-pit_decile_distribution_bu_sim%>%
                      #                               filter(year==simulation_year)
                    
                        
# # II.PIT Distribution Table Income Breaks ( OLD) -----------------------------------------------------------
#     # 1.BU ----------------------------------------------------------------------
#             
#                       # Define the breakpoints and labels
#                       breaks <- c(-Inf, 0, 1, 0.5e6, 1e6, 1.5e6, 2e6, 3e6, 4e6, 5e6, 10e6, Inf)
#                       labels <- c("<0", "0", "0-0.5m", "0.5-1m", "1-1.5m", "1.5-2m", "2-3m", "3-4m", "4-5m", "5-10m", ">10m")
#                       
#         # Apply the transformations across all scenarios in PIT_BU_list
#                       combined_dt_bins_fun <- rbindlist(lapply(names(PIT_BU_list), function(scenario) {
#                         # Extract the data frame for each scenario
#                         data <- PIT_BU_list[[scenario]] %>%
#                           select(id_n, weight, g_total_gross, pitax) %>%
#                           mutate(
#                             weight_g = weight * g_total_gross,
#                             bin_group = cut(g_total_gross, breaks = breaks, labels = labels, right = FALSE)
#                           ) %>%
#                           # Add the scenario identifier to the data frame
#                           mutate(scenario = scenario)
#                         
#                         # Convert to data.table for efficient operations
#                         as.data.table(data)
#                       }))
#                       
#                       # Calculate the sum of pitax for each bin_group and scenario
#                       pit_result_bins <- combined_dt_bins_fun[, .(sum_calc_pitax = sum(pitax)), by = .(bin_group, scenario)]
#                       
#                       # Calculate the sum for the "ALL" category for each scenario
#                       all_scenarios <- combined_dt_bins_fun[, .(bin_group = "ALL", sum_calc_pitax = sum(pitax)), by = scenario]
#                       
#                       # Combine the results with the "ALL" category
#                       pit_result_bins_bu <- rbind(pit_result_bins, all_scenarios, fill = TRUE)
#                       
#                       # Add the year column using the forecast_horizon vector
#                       pit_result_bins_bu[, year := forecast_horizon[match(scenario, scenarios)]]
#                       
#           
#     # Chart -------------------------------------------------------------------
#     
#             pit_result_bins_bu_sub <- pit_result_bins_bu %>%
#               filter(year == simulation_year) %>%
#               filter(bin_group != "ALL" & bin_group != "0")
#         
#     # 2.SIM -------------------------------------------------------------------
#             
#                       combined_dt_bins_fun <- rbindlist(lapply(names(PIT_SIM_list), function(scenario) {
#                         # Extract the data frame for each scenario
#                         data <- PIT_SIM_list[[scenario]] %>%
#                           select(id_n, weight, g_total_gross, pitax) %>%
#                           mutate(
#                             weight_g = weight * g_total_gross,
#                             bin_group = cut(g_total_gross, breaks = breaks, labels = labels, right = FALSE)
#                           ) %>%
#                           # Add the scenario identifier to the data frame
#                           mutate(scenario = scenario)
#                         
#                         # Convert to data.table for efficient operations
#                         as.data.table(data)
#                       }))
#                       
#                       # Calculate the sum of pitax for each bin_group and scenario
#                       pit_result_bins <- combined_dt_bins_fun[, .(sum_calc_pitax = sum(pitax)), by = .(bin_group, scenario)]
#                       
#                       # Calculate the sum for the "ALL" category for each scenario
#                       all_scenarios <- combined_dt_bins_fun[, .(bin_group = "ALL", sum_calc_pitax = sum(pitax)), by = scenario]
#                       
#                       # Combine the results with the "ALL" category
#                       pit_result_bins_sim <- rbind(pit_result_bins, all_scenarios, fill = TRUE)
#                       
#                       # Add the year column using the forecast_horizon vector
#                       pit_result_bins_sim[, year := forecast_horizon[match(scenario, scenarios)]]
#                       
#         
#     
#     # Chart -------------------------------------------------------------------
#     
#             pit_result_bins_sim_sub <- pit_result_bins_sim %>%
#               filter(year == simulation_year) %>%
#               filter(bin_group != "ALL" & bin_group != "0")%>%
#               select(-c(scenario,year))
#             
#             
#             # Calculate the sum of the 'sum_calc_pitax' column
#             total_pitax <- sum(pit_result_bins_sim_sub$sum_calc_pitax)
#             pit_result_bins_sim_sub[, percentage_structure := (sum_calc_pitax / total_pitax) * 100]
#             pit_result_bins_sim_sub[, sum_calc_pitax := round(sum_calc_pitax / 1e06, 1)]
#             
#             pit_result_bins_sim_sub$percentage_structure<-round(pit_result_bins_sim_sub$percentage_structure,1)

# Testing new -------------------------------------------------------------

            
            # II.PIT Distribution Table Income Breaks ( NEW-TEST)-----------------------------------------------------------
            # 1.BU ----------------------------------------------------------------------
            
            # Define the breakpoints and labels
            
            
            breaks <- c( -Inf, 0,1e-09,500000.0,1000000.0,1500000.0,2000000.0,3000000.0,4000000.0,5000000.0,10000000.0,9e+99)
            labels <- c("<0","=0","0-0.5 m","0.5-1m","1-1.5m","1.5-2m","2-3m","3-4m","4-5m","5-10m",">10m")
            
            
            # Apply the transformations across all scenarios in pit_BU_list
            combined_dt_bins_fun <- rbindlist(lapply(names(PIT_BU_list), function(scenario) {
              # Extract the data frame for each scenario
              data <- PIT_BU_list[[scenario]] %>%
                select(id_n, weight, g_total_gross, pitax) %>%
                mutate(
                  weight_g = weight * g_total_gross,
                  bin_group = cut(g_total_gross, breaks = breaks, labels = labels, right = FALSE)
                ) %>%
                # Add the scenario identifier to the data frame
                mutate(scenario = scenario)
              
              # Convert to data.table for efficient operations
              as.data.table(data)
            }))
            
            # Calculate the sum of calc_pit for each bin_group and scenario
            pit_result_bins <- combined_dt_bins_fun[, .(sum_calc_pitax = sum(pitax)), by = .(bin_group, scenario)]
            
            # Calculate the sum for the "ALL" category for each scenario
            all_scenarios <- combined_dt_bins_fun[, .(bin_group = "ALL", sum_calc_pitax = sum(pitax)), by = scenario]
            
            # Combine the results with the "ALL" category
            pit_result_bins_bu <- rbind(pit_result_bins, all_scenarios, fill = TRUE)
            
            # Add the year column using the forecast_horizon vector
            pit_result_bins_bu[, year := forecast_horizon[match(scenario, scenarios)]]
            
            
            # Chart -------------------------------------------------------------------
            
            pit_result_bins_bu_sub <- pit_result_bins_bu %>%
              filter(year == SimulationYear) %>%
              filter(bin_group != "ALL" & bin_group != "0")
            
            # 2.SIM -------------------------------------------------------------------
            
            combined_dt_bins_fun <- rbindlist(lapply(names(PIT_SIM_list), function(scenario) {
              # Extract the data frame for each scenario
              data <- PIT_SIM_list[[scenario]] %>%
                select(id_n, weight, g_total_gross, pitax) %>%
                mutate(
                  weight_g = weight * g_total_gross,
                  bin_group = cut(g_total_gross, breaks = breaks, labels = labels, right = FALSE)
                ) %>%
                # Add the scenario identifier to the data frame
                mutate(scenario = scenario)
              
              # Convert to data.table for efficient operations
              as.data.table(data)
            }))
            
            # Calculate the sum of pitax for each bin_group and scenario
            pit_result_bins <- combined_dt_bins_fun[, .(sum_calc_pitax = sum(pitax)), by = .(bin_group, scenario)]
            
            # Calculate the sum for the "ALL" category for each scenario
            all_scenarios <- combined_dt_bins_fun[, .(bin_group = "ALL", sum_calc_pitax = sum(pitax)), by = scenario]
            
            # Combine the results with the "ALL" category
            pit_result_bins_sim <- rbind(pit_result_bins, all_scenarios, fill = TRUE)
            
            # Add the year column using the forecast_horizon vector
            pit_result_bins_sim[, year := forecast_horizon[match(scenario, scenarios)]]
            
            
            
            # Chart -------------------------------------------------------------------
            
            pit_result_bins_sim_sub <- pit_result_bins_sim %>%
              filter(year == SimulationYear) %>%
              filter(bin_group != "ALL" & bin_group != "0")%>%
              select(-c(scenario,year))
            
            
            # Reorder the bin_group factor
            pit_result_bins_sim_sub[, bin_group := factor(bin_group, levels =  c("<0","=0","0-0.5 m","0.5-1m","1-1.5m","1.5-2m","2-3m","3-4m","4-5m","5-10m",">10m"))]
            
            # Order the data.table by the new factor levels
            setorder(pit_result_bins_sim_sub, bin_group)
            # test ovde
            pit_result_bins_sim_sub$sum_calc_pitax<-pit_result_bins_sim_sub$sum_calc_pitax/1e06
            pit_result_bins_sim_sub$sum_calc_pitax<-round(pit_result_bins_sim_sub$sum_calc_pitax,1)
            
            
            
            
         
            
    # Removing of objects        
            
    #rm(PIT_BU_list,PIT_SIM_list,selected_gross_desc_tbl,selected_gross_nace_tbl)
    gc(TRUE)
           
            
    