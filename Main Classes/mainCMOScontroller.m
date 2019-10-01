classdef mainCMOScontroller < handle
    %Main CMOS data handle to control GUI and access data structures
    properties

    end
    properties(Access = private)
        handles %figure handle structure
        FigHandle;
        CMOSData;
        SelectedIndex;
    end
    methods
        function obj = mainCMOScontroller(FigHandle)
            obj.handles = guidata(FigHandle);
            obj.FigHandle = FigHandle;
        end
        function LoadSif(obj)
            obj.CMOSData = [];
            obj.CMOSData = SifFile(obj.handles); %Load and populate imagedata
            waitfor(obj.CMOSData.Initialized,'Value');
            obj.LoadRoutine();
        end
        function SelectImage(obj,idx)
            obj.SelectedIndex = idx; %write selected index to memory
            if ~isempty(obj.CMOSData.ExtractMatrix(idx))
                obj.ShowImage(idx)
            end
        end
    end
    methods(Access = private)
        function LoadRoutine(obj)
            Label = {'FileName'};
            data = obj.CMOSData.FileNames';
            set(obj.handles.FileTable,'Data',data);
            set(obj.handles.FileTable,'ColumnName',Label);
            obj.ShowImage(1);
        end
        function ShowImage(obj,idx)
            [imMatrix,~,~] = obj.CMOSData.ExtractMatrix(idx);
            axes(obj.handles.MainWindow);
            imagesc(imMatrix);set(obj.handles.TitleEdit,'String',obj.CMOSData.FileNames{idx});
        end
    end
end