#' Linear mixed effects model used in MEMHDX tools
#' @param data data.table of deuteration curves
#' @param significance_level significance level for testing
#' @import lmerTest
#' @export
memhdx_model = function(data, significance_level = 0.05) {

  States = unique(data$State)

  Time = c("continuous", "categorical", "continuous")
  Transformation = c("identity", "identity", "log")

  aic = rep(NA, 3)
  loglik = rep(NA, 3)
  Test_statistic = rep(NA, 3)
  p_value = rep(NA, 3)

  # continuous, identity
  model = lmerTest::lmer(Mass ~ Exposure*State + (1|Rep),
               data = data,
               REML = FALSE)
  model_reduced = lmerTest::lmer(Mass ~ Exposure + (1|Rep),
                       data = data,
                       REML = FALSE)
  result = anova(model, model_reduced)
  aic[1] = AIC(model)
  loglik[1] = logLik(model)
  Test_statistic[1] = result$Chisq[2]
  p_value[1] = result$`Pr(>Chisq)`[2]


  # categorical, identity
  model = lmerTest::lmer(Mass ~ factor(Exposure)*State + (1|Rep),
               data = data,
               REML = FALSE)
  model_reduced = lmerTest::lmer(Mass ~ factor(Exposure) + (1|Rep),
                       data = data,
                       REML = FALSE)
  result = anova(model, model_reduced)
  aic[2] = AIC(model)
  loglik[2] = logLik(model)
  Test_statistic[2] = result$Chisq[2]
  p_value[2] = result$`Pr(>Chisq)`[2]

  # continuous, log
  model = lmerTest::lmer(Mass ~ log(Exposure + 1)*State + (1|Rep),
               data = data,
               REML = FALSE)
  model_reduced = lmerTest::lmer(Mass ~ log(Exposure+1) + (1|Rep),
               data = data,
               REML = FALSE)
  result = anova(model, model_reduced)
  aic[3] = AIC(model)
  loglik[3] = logLik(model)
  Test_statistic[3] = result$Chisq[2]
  p_value[3] = result$`Pr(>Chisq)`[2]

  data.table(Test = "MEMHDX lmm",
             State_1 = States[1],
             State_2 = States[2],
             Test_statistic = Test_statistic,
             P_value = p_value,
             Significant_difference = (p_value <= significance_level),
             Time = Time,
             Transformation = Transformation,
             AIC = aic,
             logLik = loglik)
}
