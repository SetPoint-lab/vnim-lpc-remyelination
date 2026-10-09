library(lme4)
library(lmerTest)  
library(ggplot2)

setwd()
data <- read.csv("g_ratio_results_forR.csv",header = TRUE, stringsAsFactors = FALSE)  

data$g_ratio <- as.numeric(data$g_ratio)  
data$Feret_d   <- as.numeric(data$Feret_d)

data$Animal    <- as.factor(data$Animal)  
data$Treatment <- as.factor(data$Treatment)

# Model
model_int <- lmer(g_ratio ~ Feret_d * Treatment + (1 | Animal), data = data)  

# Results  
cat("Model Summary (Interaction)")  
print(summary(model_int))

cat("Type III ANOVA")  
print(anova(model_int, type = 3))

cat("95% Confidence Intervals")  
print(confint(model_int, parm = "beta_", method = "Wald"))

cat("Random Effects")  
print(VarCorr(model_int))
