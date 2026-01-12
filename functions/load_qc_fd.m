function mean_fd = load_qc_fd(sub_id, file_path)

json_name = [file_path, '/', sub_id, '.json'];
json_data = loadjson(json_name);
json_data = json_data.subjects{1,1};
mean_fd = json_data.mean_fd;

end
