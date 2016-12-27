# SPEC related functions

# Get SPEC Value

def get_spec_value(spec_type,model_name)
  file_array = File.readlines("information/spec#{spec_type}.csv")
  spec_array = file_array.grep(/#{model_name}/)[0]
  if spec_array
    spec_info  = CSV.parse(spec_array)[0]
    spec_name  = spec_info[0]
    spec_value = spec_info[3]
  end
  return spec_name,spec_value
end

# Process SPEC Value

def process_spec_value(spec_type,table)
  model_name = get_model_name()
  (spec_name,spec_value) = get_spec_value(spec_type,model_name)
  if spec_name
    table = handle_table("row",spec_name,spec_value,table)
  end
  return table
end

# Process SPEC CPU

def process_spec_cpu(table)
  table = process_spec_value("cpu",table)
  return table
end

# Process SPEC JBB

def process_spec_jbb(table)
  table = process_spec_value("jbb",table)
  return table
end

# Procss SPEC Web

def process_spec_web(table)
  table = process_spec_value("web",table)
  return table
end

# Process SPEC

def process_spec()
  table = handle_table("title","SPEC Information","","")
  table = process_spec_cpu(table)
  table = process_spec_jbb(table)
  table = process_spec_web(table)
  table = handle_table("end","","",table)
  return table
end
