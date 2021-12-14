local ObjectPool = {
    New = function(self,BaseObject)
        local Pool = {
            Contents = {}
        }
        
        function Pool:Add(Object)
            Object.Parent = nil
            table.insert(self.Contents,Object)
        end

        function Pool:Get()
            if #self.Contents > 0 then
                local GotResource = self.Contents[1]
                table.remove(self.Contents,1)
                return GotResource
            else
                return BaseObject:Clone()
            end
        end

        function Pool:Clean()
            for _,v in pairs(Pool.Contents) do
                v:Destroy()
                BaseObject:Destroy()
                self.Contents = nil
                self.Add = nil
                self.Get = nil
                self.Clean = nil
            end
        end
        
        return Pool
    end
}

return ObjectPool