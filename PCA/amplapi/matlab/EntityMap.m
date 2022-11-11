classdef EntityMap < EntityMapBase

methods
    function result = subsref(self, key)
        switch key(1).type
             case '()'
                 if(length(key) < 2 && length(key.subs) == 1)
                    if(ischar(key.subs{1}))
                        entity = self.impl.find(key.subs{1});
                        if(isa(entity, 'com.ampl.Variable'))
                            result = Variable(entity);
                        elseif(isa(entity, 'com.ampl.Constraint'))
                            result = Constraint(entity);
                        elseif(isa(entity, 'com.ampl.Parameter'))
                            result = Parameter(entity);
                        elseif(isa(entity, 'com.ampl.Objective'))
                            result = Objective(entity);
                        elseif(isa(entity, 'com.ampl.Set'))
                            result = Set(entity);
                        else
                            result = entity;
                        end
                    elseif(1 <= int64(key.subs{1}) && int64(key.subs{1}) <= self.impl.size())
                        it = self.iterator();
                        for i = 1:int64(key.subs{1})
                            result = it.next();
                        end
                    else
                        error('EntityList:subref', 'Index out of range')
                    end
                else
                    error('Entity:subsref', 'Not a supported subscripted reference')
                end
                return
             case '.'
                result = builtin('subsref',self,key);
                return
             case '{}'
                error('Entity:subsref', 'Not a supported subscripted reference')
        end
    end

    function obj = EntityMap(impl)
        obj@EntityMapBase(impl);
    end

    function disp(self)
        disp(self.toString());
    end

end
end
