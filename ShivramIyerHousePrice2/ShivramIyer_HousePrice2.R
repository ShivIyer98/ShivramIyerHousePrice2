
# Open codes --------------------------------------------------------------

setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
### set working directory to where the file is located
# Or go to [Session > Set working directory > To source file location]
file.edit('./project/required/requirements.R')
file.edit('./project/src/models/train_model.R')
### If it does not work, close R and open 'run_project.R' again


# Run codes ---------------------------------------------------------------

source('./project/required/requirements.R')
source('./project/src/models/train_model.R')
