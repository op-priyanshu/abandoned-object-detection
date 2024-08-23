classdef ObjectTracker
    properties
        center_points = containers.Map();
        id_count = 0;
        abandoned_temp = containers.Map();
    end
    
    methods
        function obj = ObjectTracker()
        end
        
        function [objects_bbs_ids, abandoned_object] = update(obj, objects_rect)
            objects_bbs_ids = {};
            abandoned_object = {};
            
            for i = 1:numel(objects_rect)
                rect = objects_rect{i};
                x = rect(1);
                y = rect(2);
                w = rect(3);
                h = rect(4);
                %center points of detected object
                cx = (x + x + w) / 2;
                cy = (y + y + h) / 2;
                
                same_object_detected = false;

                % Iterate over existing tracked objects
                keys = obj.center_points.keys;
                for j = 1:numel(keys)
                    id = keys{j};
                    pt = obj.center_points(id);

                    % Calculate distance between current object and tracked object
                    distance = hypot(cx - pt{1}, cy - pt{2});

                    % If distance is below threshold, update tracked object
                    if distance < 25
                        obj.center_points(id) = {cx, cy};

                        objects_bbs_ids{end+1} = [double(x),double(y),double(w),double(h),double(id),double(distance)];
                        same_object_detected = true;

                        %inserting abandoned object 
                        if isKey(obj.abandoned_temp, id)
                            if distance < 1
                                if obj.abandoned_temp(id) > 100
                                    abandoned_object{end+1} = [double(id),double(x),double(y),double(w),double(h),double(distance)];
                                else
                                    obj.abandoned_temp(id) = obj.abandoned_temp(id) + 1;
                                end
                            end
                        end
                        
                        break;
                    end
                end
                % If the detected object is not associated with any existing tracked object, assign a new ID
                if ~same_object_detected
                    key = num2str(obj.id_count);
                    obj.center_points(key) = {cx, cy};
                    obj.abandoned_temp(key) = 1;
                    objects_bbs_ids{end+1}  = [double(x),double(y),double(w),double(h),double(obj.id_count) , NaN];
                    obj.id_count = obj.id_count + 1;
                end
            end
           
        end
    end
end
