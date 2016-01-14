# Get ZFS filesystem list

def get_zfs_list()
  file_name  = "/disks/zfs/zfs_list.out"
  file_array = exp_file_to_array(file_name)
  return file_array
	return
end

# Get ZFS pool list

def get_zpool_list()
  file_name  = "/disks/zfs/zpool_list.out"
  file_array = exp_file_to_array(file_name)
  return file_array
	return
end

# Get ZFS snapshot list

def get_zfs_snapshots()
  file_name  = "/disks/zfs/zpool_list-t_snapshot.out"
  file_array = exp_file_to_array(file_name)
  return file_array
	return
end


# Process ZFS

def process_zfs()
	process_zfs_list()
	process_zpool_list()
	process_zfs_snapshots()
	return
end

# Process ZFS list

def process_zfs_list()
	file_array = get_zfs_list()
	if file_array.to_s.match(/[A-Z]|[a-z]|[0-9]/)
		title = "ZFS Filesystems"
		row   = [ 'Name', 'Used', 'Avail', 'Refer', 'Mount' ]
		table = handle_table("title",title,row,"")
		file_array.each do |line|
			if !line.match(/^NAME/)
				items = line.split(/\s+/)
				name  = items[0]
				used  = items[1]
				avail = items[2]
				refer = items[3]
				if $masked == 1
					mount = "MASKED"
				else
					mount = items[4]
				end
				row   = [ name, used, avail, refer, mount ]
				table = handle_table("row","",row,table)
			end
		end
		table = handle_table("end","","",table)
	else
		puts
		puts "No ZFS filesystem information available"
	end
	return
end

# Process ZFS list

def process_zfs_snapshots()
	file_array = get_zfs_snapshots()
	if file_array.to_s.match(/[A-Z]|[a-z]|[0-9]/)
		title = "ZFS Snapshots"
		row   = [ 'Name', 'Used', 'Avail', 'Refer', 'Mount' ]
		table = handle_table("title",title,row,"")
		file_array.each do |line|
			if !line.match(/^NAME/)
				items = line.split(/\s+/)
				if $masked == 1
					name = "MASKED"
				else
					name = items[0]
				end
				used  = items[1]
				avail = items[2]
				refer = items[3]
				if $masked == 1
					mount = "MASKED"
				else
					mount = items[4]
				end
				row   = [ name, used, avail, refer, mount ]
				table = handle_table("row","",row,table)
			end
		end
		table = handle_table("end","","",table)
	else
		puts
		puts "No ZFS snapshot information available"
	end
	return
end

# Process ZFS pool list

def process_zpool_list()
	file_array = get_zpool_list()
	if file_array.to_s.match(/[A-Z]|[a-z]|[0-9]/)
		title = "ZFS Pools"
		row   = [ 'Name', 'Size', 'Allocated', 'Free', 'Capacity', 'De-dupe', 'Health', 'Alt Root' ]
		table = handle_table("title",title,row,"")
		file_array.each do |line|
			if !line.match(/^NAME/)
				items  = line.split(/\s+/)
				if $masked == 1
					name = "MASKED"
				else
					name = items[0]
				end
				size   = items[1]
				alloc  = items[2]
				free   = items[3]
				cap    = items[4]
				dedup  = items[5]
				health = items[6]
				alt    = items[7]
				row    = [ name, size, alloc, free, cap, dedup, health, alt  ]
				table  = handle_table("row","",row,table)
			end
		end
		table = handle_table("end","","",table)
	else
		puts
		puts "No ZFS pool information available"
	end
	return
end