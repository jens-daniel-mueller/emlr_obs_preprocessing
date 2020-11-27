#### Calculate derived variables ####

# calculate cstar
b_cstar <- function(tco2, phosphate, talk){

  cstar = tco2  - (parameters$rCP * phosphate)  - 0.5 * (talk - (parameters$rNP * phosphate))
  return(cstar)

  }


# calculate phosphate star
b_phosphate_star <- function(phosphate, oxygen){

  phosphate_star = phosphate + (oxygen / parameters$rPO)  - parameters$rPO_offset
  return(phosphate_star)

  }


# calculate apparent oxygen utilization
# supplied oxygen data must be in mol kg-1

b_aou <- function(sal, tem, depth, oxygen) {

  oxygen_sat_m3 <- gas_satconc(
    S = sal,
    t = tem,
    P = 1.013253,
    species = "O2"
  )

  rho <-
    gsw_pot_rho_t_exact(SA = sal,
                        t = tem,
                        p = depth,
                        p_ref = 10.1325)

  oxygen_sat_kg = oxygen_sat_m3 * (1000 / rho)

  aou = oxygen_sat_kg - oxygen

  return(aou)

}


#### Map variables from MLR coefficients ####

# map cant from MLR coefficients and predictor variables

b_cant <- function(df) {

  df <- df %>%
    mutate(cant = `delta_coeff_(Intercept)` +
             delta_coeff_aou * aou +
             delta_coeff_oxygen * oxygen +
             delta_coeff_phosphate * phosphate +
             delta_coeff_phosphate_star * phosphate_star +
             delta_coeff_silicate * silicate +
             delta_coeff_sal * sal +
             delta_coeff_tem * tem)

  return(df)

}


# map cant predictor contributions from MLR coefficients and predictor variables

b_cant_predictor <- function(df) {

  df <- df %>%
    mutate(
      cant_intercept = `delta_coeff_(Intercept)`,
      cant_aou = delta_coeff_aou * aou,
      cant_oxygen = delta_coeff_oxygen * oxygen,
      cant_phosphate = delta_coeff_phosphate * phosphate,
      cant_phosphate_star = delta_coeff_phosphate_star * phosphate_star,
      cant_silicate = delta_coeff_silicate * silicate,
      cant_sal = delta_coeff_sal * sal,
      cant_tem = delta_coeff_tem * tem,
      cant_sum = cant_intercept +
        cant_aou +
        cant_oxygen +
        cant_phosphate +
        cant_phosphate_star +
        cant_silicate +
        cant_sal +
        cant_tem
    )

  return(df)

}

# map cstar from MLR coefficients and predictor variables

b_cstar_model <- function(df) {

  df <- df %>%
    mutate(cstar =
             `coeff_(Intercept)` +
             coeff_aou * aou +
             coeff_oxygen * oxygen +
             coeff_phosphate * phosphate +
             coeff_phosphate_star * phosphate_star +
             coeff_silicate * silicate +
             coeff_sal * sal +
             coeff_tem * tem)

  return(df)

}
