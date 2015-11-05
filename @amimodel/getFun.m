function this = getFun(this,HTable,funstr)
    % getFun generates symbolic expressions for the requested function.
    %
    % Parameters:
    %  HTable: struct with hashes of symbolic definition from the previous
    %  compilation @type struct
    %  funstr: function for which symbolic expressions should be computed @type string
    %
    % Return values:
    %  this: updated model definition object @type amimodel

    deps = this.getFunDeps(funstr);
    
    [this,cflag] = this.checkDeps(HTable,deps);
    
    nx = this.nx;
    nr = this.nr;
    ny = this.ny;
    ndisc = this.ndisc;
    np = this.np;
    
    hflag = 1;
    if(cflag)
        fprintf([funstr ' | '])
        switch(funstr)
            case 'xdot'
                if(strcmp(this.wtype,'iw'))
                    if(size(this.sym.xdot,2)>size(this.sym.xdot,1))
                        this.sym.xdot = -transpose(this.sym.M*this.strsym.dxs)+this.sym.xdot;
                    else
                        this.sym.xdot = -this.sym.M*this.strsym.dxs+this.sym.xdot;
                    end
                    
                    this.id = sum(this.sym.M,2)~=0;
                else
                    this.id = zeros(this.nx,1);
                end
                
            case 'dfdx'
                this.sym.dfdx=jacobian(this.sym.xdot,this.strsym.xs);
                
            case 'J'
                if(strcmp(this.wtype,'iw'))
                    syms cj
                    this.sym.J = this.sym.dfdx - cj*this.sym.M;
                else
                    this.sym.J = jacobian(this.sym.xdot,this.strsym.xs);
                end
                
            case 'JB'
                this.sym.JB=-transpose(this.sym.J);
                
            case 'dxdotdp'
                this.sym.dxdotdp=jacobian(this.sym.xdot,this.strsym.ps);
                
            case 'sx0'
                this.sym.sx0=jacobian(this.sym.x0,this.strsym.ps);
                
            case 'sdx0'
                this.sym.sdx0=jacobian(this.sym.dx0,this.strsym.ps);
                
            case 'sxdot'
                if(strcmp(this.wtype,'iw'))
                    this.sym.sxdot=this.sym.dfdx*this.strsym.sx-this.sym.M*this.strsym.sdx+this.sym.dxdotdp;
                else
                    this.sym.sxdot=this.sym.J*this.strsym.sx+this.sym.dxdotdp;
                end
                
            case 'dydx'
                this.sym.dydx=jacobian(this.sym.y,this.strsym.xs);
                
            case 'dydp'
                this.sym.dydp=jacobian(this.sym.y,this.strsym.ps);
                
            case 'sy'
                this.sym.sy=this.sym.dydp + this.sym.dydx*this.strsym.sx ;
                
                % events
            case 'drootdx'
                if(this.nxtrue > 0)
                    this.sym.drootdx = jacobian(this.sym.root,this.strsym.xs(1:this.nxtrue));
                else
                    this.sym.drootdx=jacobian(this.sym.root,this.strsym.xs);
                end
                
            case 'drootdt'
                if(this.nxtrue > 0)
                    this.sym.drootdt = diff(this.sym.root,sym('t')) ...
                        + this.sym.drootdx*this.sym.xdot(1:this.nxtrue);
                else
                    this.sym.drootdt = diff(this.sym.root,sym('t')) + this.sym.drootdx*this.sym.xdot;
                end
                
            case 'drootpdp'
                this.sym.drootpdp = jacobian(this.sym.root,this.strsym.ps);
                
            case 'drootdp'
                if(this.nxtrue > 0)
                    this.sym.drootdp = this.sym.drootpdp + this.sym.drootdx*this.sym.dxdp;
                else
                    this.sym.drootdp = this.sym.drootpdp + this.sym.drootdx*this.strsym.sx;
                end
                
            case 'sroot'
                this.sym.sroot = sym.zeros(0,np);
                if(this.nr>0)
                    for ir = 1:this.nr
                        this.sym.sroot(ir,:) = -(this.sym.drootdt(ir,:))\(this.sym.drootdp(ir,:));
                    end
                end
                
            case 's2root'
                this.sym.s2root =  sym(zeros(nr,np,np));
                % ddtaudpdp = -dgdt\(dtaudp*ddgdtdt*dtaudp + 2*ddgdpdt*dtaudp
                % + ddgdpdp)
                if(this.nr>0 && this.nxtrue > 0)
                    for ir = 1:nr
                        this.sym.s2root(ir,:,:) = -1/(this.sym.drootdt(ir))*(...
                            transpose(this.sym.sroot(ir,:))*this.sym.ddrootdtdt(ir)*this.sym.sroot(ir,:) ...
                            + squeeze(this.sym.ddrootdtdp(ir,:,:))*this.sym.sroot(ir,:) ...
                            + transpose(squeeze(this.sym.ddrootdtdp(ir,:,:))*this.sym.sroot(ir,:)) ...
                            + squeeze(this.sym.s2rootval(ir,:,:)));
                    end
                end
                
            case 'srootval'
                if(this.nr>0)
                    this.sym.srootval = this.sym.drootdp;
                else
                    this.sym.srootval = sym(zeros(0,np));
                end
                
            case 's2rootval'
                if(this.nr>0 && this.nxtrue > 0)
                    this.sym.s2rootval = this.sym.ddrootdpdp;
                else
                    this.sym.s2rootval =  sym(zeros(nr,np,np));
                end
                
            case 'dxdp'
                if(this.nr>0 && this.nxtrue > 0)
                    this.sym.dxdp = reshape(this.strsym.xs((this.nxtrue+1):end),this.nxtrue,np);
                else
                    this.sym.dxdp = sym(zeros(this.nxtrue,np));
                end
            case 'ddrootdxdx'
                this.sym.ddrootdxdx = sym(zeros(nr,this.nxtrue,this.nxtrue));
                if(this.nxtrue>0)
                    for ir = 1:nr
                        this.sym.ddrootdxdx(ir,:,:) = hessian(this.sym.root(ir),this.strsym.xs(1:this.nxtrue));
                    end
                end
                
            case 'ddrootdxdt'
                this.sym.ddrootdxdt = sym(zeros(nr,this.nxtrue));
                % ddgdxdt = ddgdxdt + ddgdxdx*dxdt
                if(this.nxtrue>0)
                    for ir = 1:nr
                        this.sym.ddrootdxdt(ir,:) = diff(this.sym.drootdx(ir,:),sym('t')) ...
                            + jacobian(this.sym.drootdx*this.sym.xdot(1:this.nxtrue),this.strsym.xs(1:this.nxtrue)) ...
                            + transpose(squeeze(this.sym.ddrootdxdx(ir,:,:))*this.sym.xdot(1:this.nxtrue));
                    end
                end
                
            case 'ddrootdtdt'
                % ddgdtdt = pddgdtpdt + ddgdxdt*dxdt
                if(this.nxtrue>0)
                    this.sym.ddrootdtdt = diff(this.sym.drootdt,sym('t')) ...
                        + this.sym.ddrootdxdt*this.sym.xdot(1:this.nxtrue);
                else
                    this.sym.ddrootdtdt = sym(zeros(size(this.sym.root)));
                end
                
            case 'ddxdtdp'
                % ddxdtdp = pddxdtpdp + ddxdtdx*dxdp
                if(this.nxtrue>0)
                    this.sym.ddxdtdp = this.sym.dxdotdp(1:this.nxtrue,:) ...
                        + this.sym.dxdotdx*this.sym.dxdp;
                else
                    this.sym.ddxdtdp = sym(zeros(nx,np));
                end
                
            case 'dxdotdx'
                this.sym.dxdotdx = jacobian(this.sym.xdot(1:this.nxtrue),this.strsym.xs(1:this.nxtrue));
                
            case 'ddrootdpdx'
                this.sym.ddrootdpdx = sym(zeros(nr,np,this.nxtrue));
                if(this.nxtrue>0)
                    for ir = 1:nr
                        this.sym.ddrootdpdx(ir,:,:) = jacobian(this.sym.drootdp(ir,:),this.strsym.xs(this.rt(1:this.nxtrue)));
                    end
                end
                
            case 'ddrootdpdt'
                % ddgdpdt =  pddgdppdt + ddgdpdx*dxdt
                this.sym.ddrootdpdt = sym(zeros(nr,np,1));
                if(this.nxtrue>0)
                    for ir = 1:nr
                        this.sym.ddrootdpdt(ir,:,:) = diff(this.sym.drootdp,sym('t')) ...
                            + transpose(permute(this.sym.ddrootdpdx(ir,:,:),[2,3,1])*this.sym.xdot(1:this.nxtrue));
                    end
                end
                
            case 'ddrootdtdp'
                % ddgdpdt =  pddgdtpdp + ddgdtdx*dxdp
                this.sym.ddrootdtdp = sym(zeros(nr,1,np));
                if(this.nxtrue>0)
                    for ir = 1:nr
                        this.sym.ddrootdtdp(ir,:,:) = jacobian(this.sym.drootdt,this.strsym.ps) ...
                            + this.sym.ddrootdxdt*this.sym.dxdp;
                    end
                end
                
            case 'drootdx_ddxdpdp'
                % dgdx*ddxdpdp
                this.sym.drootdx_ddxdpdp = sym(zeros(nr,np,np));
                if(this.nxtrue>0)
                    ddxdpdp = reshape(this.strsym.sx((this.nxtrue+1):end,:),this.nxtrue,np,np);
                    for ir = 1:nr
                        for ix = 1:this.nxtrue
                            this.sym.drootdx_ddxdpdp(ir,:,:) = this.sym.drootdx_ddxdpdp(ir,:,:) + this.sym.drootdx(ir,ix)*ddxdpdp(ix,:,:);
                        end
                    end
                end
                
            case 'ddrootdpdp'
                % ddgdpdp = pddgdppdp + ddgdpdx*dxdp + dgdx*dxdp
                this.sym.ddrootdpdp = sym(zeros(nr,np,np));
                if(this.nxtrue>0)
                    for ir = 1:nr
                        this.sym.ddrootdpdp(ir,:,:) = jacobian(this.sym.drootdp,this.strsym.ps) ...
                            + permute(this.sym.ddrootdpdx(ir,:,:),[2,3,1])*this.sym.dxdp ...
                            + squeeze(this.sym.drootdx_ddxdpdp(ir,:,:));
                    end
                end
                
                
            case 'dtdp'
                this.sym.dtdp = sym(zeros(nr,np));
                if(nr>0)
                    for ir = 1:nr
                        this.sym.dtdp(ir,:) = -(this.sym.drootdt(ir,:))\(this.sym.drootpdp(ir,:));
                    end
                end
                
            case 'dtdx'
                this.sym.dtdx = sym(zeros(0,nx));
                if(nr>0)
                    for ir = 1:nr
                        this.sym.dtdx(ir,:) = -(this.sym.drootdt(ir,:))\(this.sym.drootdx(ir,:));
                    end
                end
                
            case 'Jv'
                this.sym.Jv = this.sym.J*this.strsym.vs;
                
            case 'JvB'
                this.sym.JvB = -transpose(this.sym.J)*this.strsym.vs;
                
            case 'xBdot'
                if(strcmp(this.wtype,'iw'))
                    syms t
                    this.sym.xBdot = diff(transpose(this.sym.M),t)*this.strsym.xBs + transpose(this.sym.M)*this.strsym.dxBs - transpose(this.sym.J)*this.strsym.xBs;
                else
                    this.sym.xBdot = -transpose(this.sym.J)*this.strsym.xBs;
                end
                
            case 'qBdot'
                this.sym.qBdot = -transpose(this.strsym.xBs)*this.sym.dxdotdp;
                
            case 'dsigma_ydp'
                this.sym.dsigma_ydp = jacobian(this.sym.sigma_y,this.strsym.ps);
                
            case 'dsigma_tdp'
                this.sym.dsigma_tdp = jacobian(this.sym.sigma_t,this.strsym.ps);
                
            case 'rdisc'
                % bogus variable
                syms foo
                % discontinuities
                ndisc = 0;
                for ix = 1:length(this.sym.xdot)
                    tmp_str = char(this.sym.xdot(ix));
                    idx_start = [strfind(tmp_str,'heaviside') + 9,strfind(tmp_str,'dirac') + 5]; % find
                    if(~isempty(idx_start))
                        for iocc = 1:length(idx_start) % loop over occurances
                            brl = 1; % init bracket level
                            str_idx = idx_start(iocc); % init string index
                            % this code should be improved at some point
                            while brl >= 1 % break as soon as initial bracket is closed
                                str_idx = str_idx + 1;
                                if(strcmp(tmp_str(str_idx),'(')) % increase bracket level
                                    brl = brl + 1;
                                end
                                if(strcmp(tmp_str(str_idx),')')) % decrease bracket level
                                    brl = brl - 1;
                                end
                            end
                            idx_end = str_idx;
                            arg = tmp_str((idx_start(iocc)+1):(idx_end-1));
                            if(ndisc>0)
                                if(strcmp(tmp_str(max((idx_start(iocc)-9),1):(idx_start(iocc)-1)),'heaviside'))
                                    if(~any(isequaln(abs(this.sym.rdisc),abs(sym(arg)))))
                                        ndisc = ndisc + 1;
                                        this.sym.rdisc(ndisc) = sym(arg);
                                    else
                                    end
                                elseif(strcmp(tmp_str(max((idx_start(iocc)-5),1):(idx_start(iocc)-1)),'dirac'))
                                    if(~any(isequaln(abs(this.sym.rdisc),abs(sym(arg)))))
                                        if(isempty(strfind(arg,','))) % no higher order derivatives
                                            ndisc = ndisc + 1;
                                            this.sym.rdisc(ndisc) = sym(arg);
                                        end
                                    else
                                    end
                                end
                            else
                                if(isempty(strfind(arg,',')))
                                    ndisc = ndisc + 1;
                                    this.sym.rdisc(ndisc) = sym(arg);
                                end
                            end
                        end
                    end
                end
                
                this.ndisc = ndisc;
                if(ndisc == 0)
                    this.sym.rdisc = [];
                end
                
            case 'deltadisc'
                syms foo
                
                this.sym.deltadisc = sym(zeros(nx,ndisc));
                this.sym.f = sym(zeros(nx,ndisc));
                this.sym.v = sym(zeros(nx,ndisc));
                this.sym.w = sym(zeros(nx,ndisc));
                this.sym.z = sym(zeros(nx,ndisc));
                
                % convert deltas in xdot
                if(ndisc>0)
                    for ix = 1:nx
                        summand_ignore = [];
                        tmp_str_d = char(this.sym.xdot(ix));
                        idx_start_d = strfind(tmp_str_d,'dirac' ) + 5 ;
                        if(~isempty(idx_start_d))
                            for iocc_d = 1:length(idx_start_d)
                                brl = 1; % init bracket level
                                str_idx_d = idx_start_d(iocc_d); % init string index
                                % this code should be improved at some point
                                while brl >= 1 % break as soon as initial bracket is closed
                                    str_idx_d = str_idx_d + 1;
                                    if(strcmp(tmp_str_d(str_idx_d),'(')) % increase bracket level
                                        brl = brl + 1;
                                    end
                                    if(strcmp(tmp_str_d(str_idx_d),')')) % decrease bracket level
                                        brl = brl - 1;
                                    end
                                end
                                idx_end_d = str_idx_d;
                                arg_d = tmp_str_d((idx_start_d(iocc_d)+1):(idx_end_d-1));
                                if(strfind(arg_d,',')) % higher order derivatives
                                    if(regexp(tmp_str_d((idx_start_d(iocc_d)):(idx_start_d(iocc_d)+2)),'\([1-2],'))
                                        arg_d = tmp_str_d((idx_start_d(iocc_d)+3):(idx_end_d-1));
                                    elseif(regexp(tmp_str_d((idx_end_d-3):(idx_end_d)),', [1-2])'))
                                        arg_d = tmp_str_d((idx_start_d(iocc_d)+1):(idx_end_d-4));
                                    end
                                end
                                str_arg_d = ['dirac(' char(sym(arg_d)) ')' ]; % the char(sym(...)) hopefully ensures consistent ordering of the argument
                                str_arg_d1 = ['dirac(1, ' char(sym(arg_d)) ')' ]; % the char(sym(...)) hopefully ensures consistent ordering of the argument
                                str_arg_1d = ['dirac(' char(sym(arg_d)) ', 1)' ]; % the char(sym(...)) hopefully ensures consistent ordering of the argument
                                str_arg_d2 = ['dirac(2, ' char(sym(arg_d)) ')' ]; % the char(sym(...)) hopefully ensures consistent ordering of the argument
                                str_arg_2d = ['dirac(' char(sym(arg_d)) ', 2)' ]; % the char(sym(...)) hopefully ensures consistent ordering of the argument
                                dotarg_d = diff(sym(arg_d),'t') + jacobian(sym(arg_d),this.strsym.xs)*this.sym.xdot;
                                % find the corresponding discontinuity
                                for idisc = 1:ndisc;
                                    if(isequaln(abs(sym(arg_d)),abs(this.sym.rdisc(idisc))))
                                        if(length(children(this.sym.xdot(ix)+foo))==2) % if the term is not a sum
                                            summands = this.sym.xdot(ix);
                                        else
                                            summands = children(this.sym.xdot(ix));
                                        end
                                        for is = 1:length(summands)
                                            if(isempty(find(is==summand_ignore,1))) % check if we already added that term
                                                str_summand = char(summands(is));
                                                if(strfind(str_summand,str_arg_d)) % v_i
                                                    this.sym.v(ix,idisc) = this.sym.v(ix,idisc) + sym(strrep(str_summand,str_arg_d,char(1/abs(dotarg_d))));
                                                    summand_ignore = [summand_ignore is];
                                                elseif(strfind(str_summand,str_arg_d1)) % w_i
                                                    this.sym.w(ix,idisc) = this.sym.w(ix,idisc) ...
                                                        + sym(strrep(str_summand,str_arg_d1,char(dotarg_d/abs(dotarg_d))));
                                                    summand_ignore = [summand_ignore is];
                                                elseif(strfind(str_summand,str_arg_1d)) % w_i
                                                    this.sym.w(ix,idisc) = this.sym.w(ix,idisc) ...
                                                        + sym(strrep(str_summand,str_arg_1d,char(dotarg_d/abs(dotarg_d))));
                                                    summand_ignore = [summand_ignore is];
                                                elseif(strfind(str_summand,str_arg_d2)) % z_i
                                                    this.sym.z(ix,idisc) = this.sym.z(ix,idisc) ...
                                                        + sym(strrep(str_summand,str_arg_d2,char(dotarg_d^2/abs(dotarg_d))));
                                                    summand_ignore = [summand_ignore is];
                                                elseif(strfind(str_summand,str_arg_2d)) % z_i
                                                    this.sym.z(ix,idisc) = this.sym.z(ix,idisc) ...
                                                        + sym(strrep(str_summand,str_arg_2d,char(dotarg_d^2/abs(dotarg_d))));
                                                    summand_ignore = [summand_ignore is];
                                                else % f
                                                    this.sym.f(ix,idisc) = this.sym.xdot(ix,idisc) + summands(is);
                                                    summand_ignore = [summand_ignore is];
                                                end
                                            end
                                        end
                                    else
                                        this.sym.f(ix,idisc) = this.sym.xdot(ix);
                                    end
                                end
                            end
                        else
                            this.sym.f(ix,:) = repmat(this.sym.xdot(ix),[1,ndisc]);
                        end
                    end
                    % compute deltadisc
                    for idisc = 1:ndisc
                        nonzero_z = any(this.sym.z(:,idisc)~=0);
                        if(nonzero_z)
                            M = jacobian(this.sym.f(:,idisc),this.strsym.xs)*this.sym.z(:,idisc) ...
                                + this.sym.w(:,idisc) ...
                                - diff(this.sym.z(:,idisc),'t') - jacobian(this.sym.z(:,idisc),this.strsym.xs)*this.sym.xdot;
                        else
                            M = this.sym.w(:,idisc);
                        end
                        nonzero_M = any(M~=0);
                        for ix = 1:nx
                            % delta_x_i =
                            % sum_j(df_idx_j*(sum_k(df_idx_k*z_k) +
                            % w_j - dot{z}_j) + v_i - dot{w}_i +
                            % ddot{z}_i
                            
                            if(this.sym.v(ix,idisc)~=0)
                                this.sym.deltadisc(ix,idisc) = this.sym.deltadisc(ix,idisc) ...
                                    +this.sym.v(ix,idisc);
                            end
                            
                            if(this.sym.w(ix,idisc)~=0)
                                this.sym.deltadisc(ix,idisc) = this.sym.deltadisc(ix,idisc) ...
                                    - diff(this.sym.w(ix,idisc),'t') - jacobian(this.sym.w(ix,idisc),this.strsym.xs)*this.sym.xdot;
                            end
                            
                            if(this.sym.z(ix,idisc)~=0)
                                this.sym.deltadisc(ix,idisc) = this.sym.deltadisc(ix,idisc) ...
                                    + diff(this.sym.z(ix,idisc),'t',2) + diff(jacobian(this.sym.z(ix,idisc),this.strsym.xs)*this.sym.xdot,'t') + ...
                                    jacobian(jacobian(this.sym.z(ix,idisc),this.strsym.xs)*this.sym.xdot,this.strsym.xs)*this.sym.xdot;
                            end
                            
                            if(nonzero_M)
                                this.sym.deltadisc(ix,idisc) = this.sym.deltadisc(ix,idisc) ...
                                    +jacobian(this.sym.f(ix,idisc),this.strsym.xs)*M;
                            end
                            
                        end
                    end
                end
                
            case 'ideltadisc'
                syms foo
                this.sym.ideltadisc = sym(zeros(np,ndisc));
                this.sym.if = sym(zeros(np,ndisc));
                this.sym.iv = sym(zeros(np,ndisc));
                this.sym.iw = sym(zeros(np,ndisc));
                this.sym.iz = sym(zeros(np,ndisc));
                
                % convert deltas in int
                if(ndisc>0)
                    for ip = 1:np
                        summand_ignore = [];
                        tmp_str_d = char(this.sym.qBdot(ip));
                        idx_start_d = strfind(tmp_str_d,'dirac' ) + 5 ;
                        if(~isempty(idx_start_d))
                            for iocc_d = 1:length(idx_start_d)
                                brl = 1; % init bracket level
                                str_idx_d = idx_start_d(iocc_d); % init string index
                                % this code should be improved at some point
                                while brl >= 1 % break as soon as initial bracket is closed
                                    str_idx_d = str_idx_d + 1;
                                    if(strcmp(tmp_str_d(str_idx_d),'(')) % increase bracket level
                                        brl = brl + 1;
                                    end
                                    if(strcmp(tmp_str_d(str_idx_d),')')) % decrease bracket level
                                        brl = brl - 1;
                                    end
                                end
                                idx_end_d = str_idx_d;
                                arg_d = tmp_str_d((idx_start_d(iocc_d)+1):(idx_end_d-1));
                                if(strfind(arg_d,',')) % higher order derivatives
                                    if(regexp(tmp_str_d((idx_start_d(iocc_d)):(idx_start_d(iocc_d)+2)),'\([1-2],'))
                                        arg_d = tmp_str_d((idx_start_d(iocc_d)+3):(idx_end_d-1));
                                    elseif(regexp(tmp_str_d((idx_end_d-3):(idx_end_d)),', [1-2])'))
                                        arg_d = tmp_str_d((idx_start_d(iocc_d)+1):(idx_end_d-4));
                                    end
                                end
                                str_arg_d = ['dirac(' char(sym(arg_d)) ')' ]; % the char(sym(...)) hopefully ensures consistent ordering of the argument
                                str_arg_d1 = ['dirac(1, ' char(sym(arg_d)) ')' ]; % the char(sym(...)) hopefully ensures consistent ordering of the argument
                                str_arg_1d = ['dirac(' char(sym(arg_d)) ', 1)' ]; % the char(sym(...)) hopefully ensures consistent ordering of the argument
                                str_arg_d2 = ['dirac(2, ' char(sym(arg_d)) ')' ]; % the char(sym(...)) hopefully ensures consistent ordering of the argument
                                str_arg_2d = ['dirac(' char(sym(arg_d)) ', 2)' ]; % the char(sym(...)) hopefully ensures consistent ordering of the argument
                                dotarg_d = diff(sym(arg_d),'t') + jacobian(sym(arg_d),this.strsym.xs)*this.sym.xdot + jacobian(sym(arg_d),this.strsym.xBs)*this.sym.xBdot;
                                % find the corresponding discontinuity
                                for idisc = 1:ndisc;
                                    if(isequaln(abs(sym(arg_d)),abs(this.sym.rdisc(idisc))))
                                        if(length(children(this.sym.qBdot(ip)+foo))==2) % if the term is not a sum
                                            summands = this.sym.qBdot(ip);
                                        else
                                            summands = children(this.sym.qBdot(ip));
                                        end
                                        for is = 1:length(summands)
                                            if(isempty(find(is==summand_ignore,1))) % check if we already added that term
                                                str_summand = char(summands(is));
                                                if(strfind(str_summand,str_arg_d)) % v_i
                                                    this.sym.iv(ip,idisc) = this.sym.iv(ip,idisc) + sym(strrep(str_summand,str_arg_d,char(1/abs(dotarg_d))));
                                                    summand_ignore = [summand_ignore is];
                                                elseif(strfind(str_summand,str_arg_d1)) % w_i
                                                    this.sym.iw(ip,idisc) = this.sym.iw(ip,idisc) ...
                                                        + sym(strrep(str_summand,str_arg_d1,char(dotarg_d/abs(dotarg_d))));
                                                    summand_ignore = [summand_ignore is];
                                                elseif(strfind(str_summand,str_arg_1d)) % w_i
                                                    this.sym.iw(ip,idisc) = this.sym.iw(ip,idisc) ...
                                                        + sym(strrep(str_summand,str_arg_1d,char(dotarg_d/abs(dotarg_d))));
                                                    summand_ignore = [summand_ignore is];
                                                elseif(strfind(str_summand,str_arg_d2)) % z_i
                                                    this.sym.iz(ip,idisc) = this.sym.iz(ip,idisc) ...
                                                        + sym(strrep(str_summand,str_arg_d2,char(dotarg_d^2/abs(dotarg_d))));
                                                    summand_ignore = [summand_ignore is];
                                                elseif(strfind(str_summand,str_arg_2d)) % z_i
                                                    this.sym.iz(ip,idisc) = this.sym.iz(ip,idisc) ...
                                                        + sym(strrep(str_summand,str_arg_2d,char(dotarg_d^2/abs(dotarg_d))));
                                                    summand_ignore = [summand_ignore is];
                                                else % f
                                                    this.sym.if(ip,idisc) = this.sym.if(ip,idisc) + summands(is);
                                                    summand_ignore = [summand_ignore is];
                                                end
                                            end
                                        end
                                    else
                                        this.sym.if(ip,idisc) = this.sym.qBdot(ip);
                                    end
                                end
                            end
                        else
                            this.sym.if(ip,:) = repmat(this.sym.qBdot(ip),[1,ndisc]);
                        end
                    end
                    % compute ideltadisc
                    for idisc = 1:ndisc
                        M = (jacobian(this.sym.f(:,idisc),this.strsym.xs)*this.sym.z(:,idisc) ...
                            + this.sym.w(:,idisc) ...
                            - diff(this.sym.z(:,idisc),'t') ...
                            - jacobian(this.sym.z(:,idisc),this.strsym.xs)*this.sym.xdot);
                        nonzero_M = any(M~=0);
                        for ip = 1:np
                            % delta_x_i =
                            % sum_j(df_idx_j*(sum_k(df_idx_k*z_k) +
                            % w_j - dot{z}_j) + v_i - dot{w}_i +
                            % ddot{z}_i
                            if(this.sym.iz(ip,idisc)~=0)
                                dizdx = jacobian(this.sym.iz(ip,idisc),this.strsym.xs);
                                dizdsxdot = jacobian(this.sym.iz(ip,idisc),this.strsym.xBs);
                                
                                this.sym.ideltadisc(ip,idisc) = this.sym.ideltadisc(ip,idisc) ...
                                    + diff(this.sym.iz(ip,idisc),'t',2) ...
                                    + diff(dizdx*this.sym.xdot,'t') ...
                                    + diff(dizdsxdot*this.sym.xBdot,'t') ...
                                    + jacobian(dizdx*this.sym.xdot,this.strsym.xs)*this.sym.xdot ...
                                    + jacobian(dizdx*this.sym.xdot,this.strsym.xBs)*this.sym.xBdot ...
                                    + jacobian(dizdsxdot*this.sym.xBdot,this.strsym.xs)*this.sym.xdot ...
                                    + jacobian(dizdsxdot*this.sym.xBdot,this.strsym.xBs)*this.sym.xBdot;
                            end
                            
                            if(this.sym.iv(ip,idisc)~=0)
                                this.sym.ideltadisc(ip,idisc) = this.sym.ideltadisc(ip,idisc) ...
                                    + this.sym.iv(ip,idisc);
                            end
                            
                            if(this.sym.iw(ip,idisc)~=0)
                                this.sym.ideltadisc(ip,idisc) = this.sym.ideltadisc(ip,idisc) ...
                                    - diff(this.sym.iw(ip,idisc),'t') - jacobian(this.sym.iw(ip,idisc),this.strsym.xs)*this.sym.xdot ...
                                    - jacobian(this.sym.iw(ip,idisc),this.strsym.xBs)*this.sym.xBdot;
                                
                            end
                            
                            if(nonzero_M)
                                this.sym.ideltadisc(ip,idisc) = this.sym.ideltadisc(ip,idisc) ...
                                    + jacobian(this.sym.if(ip,idisc),this.strsym.xs)*M;
                            end
                        end
                    end
                end
                
            case 'bdeltadisc'
                syms foo
                this.sym.bdeltadisc = sym(zeros(nx,ndisc));
                this.sym.bf = sym(zeros(nx,ndisc));
                this.sym.bv = sym(zeros(nx,ndisc));
                this.sym.bw = sym(zeros(nx,ndisc));
                this.sym.bz = sym(zeros(nx,ndisc));
                
                % convert deltas in xBdot
                if(ndisc>0)
                    for ix = 1:nx
                        summand_ignore = [];
                        tmp_str_d = char(this.sym.xBdot(ix));
                        idx_start_d = strfind(tmp_str_d,'dirac' ) + 5 ;
                        if(~isempty(idx_start_d))
                            for iocc_d = 1:length(idx_start_d)
                                brl = 1; % init bracket level
                                str_idx_d = idx_start_d(iocc_d); % init string index
                                % this code should be improved at some point
                                while brl >= 1 % break as soon as initial bracket is closed
                                    str_idx_d = str_idx_d + 1;
                                    if(strcmp(tmp_str_d(str_idx_d),'(')) % increase bracket level
                                        brl = brl + 1;
                                    end
                                    if(strcmp(tmp_str_d(str_idx_d),')')) % decrease bracket level
                                        brl = brl - 1;
                                    end
                                end
                                idx_end_d = str_idx_d;
                                arg_d = tmp_str_d((idx_start_d(iocc_d)+1):(idx_end_d-1));
                                if(strfind(arg_d,',')) % higher order derbvatbves
                                    if(regexp(tmp_str_d((idx_start_d(iocc_d)):(idx_start_d(iocc_d)+2)),'\([1-2],'))
                                        arg_d = tmp_str_d((idx_start_d(iocc_d)+3):(idx_end_d-1));
                                    elseif(regexp(tmp_str_d((idx_end_d-3):(idx_end_d)),', [1-2])'))
                                        arg_d = tmp_str_d((idx_start_d(iocc_d)+1):(idx_end_d-4));
                                    end
                                end
                                str_arg_d = ['dirac(' char(sym(arg_d)) ')' ]; % the char(sym(...)) hopefully ensures consistent ordering of the argument
                                str_arg_d1 = ['dirac(1, ' char(sym(arg_d)) ')' ]; % the char(sym(...)) hopefully ensures consistent ordering of the argument
                                str_arg_1d = ['dirac(' char(sym(arg_d)) ', 1)' ]; % the char(sym(...)) hopefully ensures consistent ordering of the argument
                                str_arg_d2 = ['dirac(2, ' char(sym(arg_d)) ')' ]; % the char(sym(...)) hopefully ensures consistent ordering of the argument
                                str_arg_2d = ['dirac(' char(sym(arg_d)) ', 2)' ]; % the char(sym(...)) hopefully ensures consistent ordering of the argument
                                dotarg_d = diff(sym(arg_d),'t') + jacobian(sym(arg_d),this.strsym.xs)*this.sym.xdot + jacobian(sym(arg_d),this.strsym.xBs)*this.sym.xBdot;
                                % find the corresponding discontinuity
                                for idisc = 1:ndisc;
                                    if(isequaln(abs(sym(arg_d)),abs(this.sym.rdisc(idisc))))
                                        if(length(children(this.sym.xBdot(ix)+foo))==2) % if the term is not a sum
                                            summands = this.sym.xBdot(ix);
                                        else
                                            summands = children(this.sym.xBdot(ix));
                                        end
                                        for is = 1:length(summands)
                                            if(isempty(find(is==summand_ignore,1))) % check bf we already added that term
                                                str_summand = char(summands(is));
                                                if(strfind(str_summand,str_arg_d)) % v_i
                                                    this.sym.bv(ix,idisc) = this.sym.bv(ix,idisc) + sym(strrep(str_summand,str_arg_d,char(1/abs(dotarg_d))));
                                                    summand_ignore = [summand_ignore is];
                                                elseif(strfind(str_summand,str_arg_d1)) % w_i
                                                    this.sym.bw(ix,idisc) = this.sym.bw(ix,idisc) ...
                                                        + sym(strrep(str_summand,str_arg_d1,char(dotarg_d/abs(dotarg_d))));
                                                    summand_ignore = [summand_ignore is];
                                                elseif(strfind(str_summand,str_arg_1d)) % w_i
                                                    this.sym.bw(ix,idisc) = this.sym.bw(ix,idisc) ...
                                                        + sym(strrep(str_summand,str_arg_1d,char(dotarg_d/abs(dotarg_d))));
                                                    summand_ignore = [summand_ignore is];
                                                elseif(strfind(str_summand,str_arg_d2)) % z_i
                                                    this.sym.bz(ix,idisc) = this.sym.bz(ix,idisc) ...
                                                        + sym(strrep(str_summand,str_arg_d2,char(dotarg_d^2/abs(dotarg_d))));
                                                    summand_ignore = [summand_ignore is];
                                                elseif(strfind(str_summand,str_arg_2d)) % z_i
                                                    this.sym.bz(ix,idisc) = this.sym.bz(ix,idisc) ...
                                                        + sym(strrep(str_summand,str_arg_2d,char(dotarg_d^2/abs(dotarg_d))));
                                                    summand_ignore = [summand_ignore is];
                                                else % f
                                                    this.sym.bf(ix,idisc) = this.sym.bf(ix,idisc) + summands(is);
                                                    summand_ignore = [summand_ignore is];
                                                end
                                            end
                                        end
                                    else
                                        this.sym.bf(ix,idisc) = this.sym.xBdot(ix);
                                    end
                                end
                            end
                        else
                            this.sym.bf(ix,:) = repmat(this.sym.xBdot(ix),[1,ndisc]);
                        end
                    end
                    % compute bdeltadisc
                    for idisc = 1:ndisc;
                        nonzero_z = any(this.sym.z(:,idisc)~=0);
                        if(nonzero_z)
                            M = jacobian(this.sym.f(:,idisc),this.strsym.xs)*this.sym.z(:,idisc) ...
                                + this.sym.w(:,idisc) ...
                                - diff(this.sym.z(:,idisc),'t') - jacobian(this.sym.z(:,idisc),this.strsym.xs)*this.sym.xdot;
                        else
                            M = this.sym.w(:,idisc);
                        end
                        nonzero_bz = any(this.sym.bz(:,idisc)~=0);
                        if(nonzero_z)
                            if(nonzero_bz)
                                N = jacobian(this.sym.bf(:,idisc),this.strsym.xs)*this.sym.z(:,idisc) ...
                                    + jacobian(this.sym.bf(:,idisc),this.strsym.xBs(:))*this.sym.bz(:,idisc) ...
                                    + this.sym.bw(:,idisc) ...
                                    - diff(this.sym.bz(:,idisc),'t') - jacobian(this.sym.bz(:,idisc),this.strsym.xs)*this.sym.xdot ...
                                    - jacobian(this.sym.bz(:,idisc),this.strsym.xBs)*this.sym.xBdot;
                            else
                                N = jacobian(this.sym.bf(:,idisc),this.strsym.xs)*this.sym.z(:,idisc) ...
                                    + this.sym.bw(:,idisc);
                            end
                        else
                            if(nonzero_bz)
                                N = jacobian(this.sym.bf(:,idisc),this.strsym.xBs(:))*this.sym.bz(:,idisc) ...
                                    + this.sym.bw(:,idisc) ...
                                    - diff(this.sym.bz(:,idisc),'t') - jacobian(this.sym.bz(:,idisc),this.strsym.xs)*this.sym.xdot ...
                                    - jacobian(this.sym.bz(:,idisc),this.strsym.xBs)*this.sym.xBdot;
                            else
                                N = this.sym.bw(:,idisc);
                            end
                        end
                        for ix = 1:nx
                            nonzero_M = any(M(ix,:)~=0);
                            nonzero_N = any(N(ix,:)~=0);
                            % delta_x_i =
                            % sum_j(df_idx_j*(sum_k(df_idx_k*z_k) +
                            % w_j - dot{z}_j) + v_i - dot{w}_i +
                            % ddot{z}_i
                            if(this.sym.bz(ix,idisc)~=0)
                                dbzdx = jacobian(this.sym.bz(ix,idisc),this.strsym.xs);
                                dbzdsxdot = jacobian(this.sym.bz(ix,idisc),this.strsym.xBs);
                                
                                this.sym.bdeltadisc(ix,idisc) = this.sym.bdeltadisc(ix,idisc) ...
                                    + diff(this.sym.bz(ix,idisc),'t',2) ...
                                    + diff(dbzdx*this.sym.xdot,'t') ...
                                    + diff(dbzdsxdot*this.sym.xBdot,'t') ...
                                    + jacobian(dbzdx*this.sym.xdot,this.strsym.xs)*this.sym.xdot ...
                                    + jacobian(dbzdx*this.sym.xdot,this.strsym.xBs)*this.sym.xBdot ...
                                    + jacobian(dbzdsxdot*this.sym.xBdot,this.strsym.xs)*this.sym.xdot ...
                                    + jacobian(dbzdsxdot*this.sym.xBdot,this.strsym.xBs)*this.sym.xBdot;
                            end
                            
                            if(this.sym.bv(ix,idisc)~=0)
                                this.sym.bdeltadisc(ix,idisc) = this.sym.bdeltadisc(ix,idisc) ...
                                    + this.sym.bv(ix,idisc);
                            end
                            
                            if(this.sym.bw(ix,idisc)~=0)
                                this.sym.bdeltadisc(ix,idisc) = this.sym.bdeltadisc(ix,idisc) ...
                                    - diff(this.sym.bw(ix,idisc),'t') - jacobian(this.sym.bw(ix,idisc),this.strsym.xs)*this.sym.xdot ...
                                    - jacobian(this.sym.bw(ix,idisc),this.strsym.xBs)*this.sym.xBdot;
                                
                            end
                            
                            if(nonzero_M)
                                this.sym.bdeltadisc(ix,idisc) = this.sym.bdeltadisc(ix,idisc) ...
                                    + jacobian(this.sym.bf(ix,idisc),this.strsym.xs)*M(ix,:);
                            end
                            if(nonzero_N)
                                this.sym.bdeltadisc(ix,idisc) = this.sym.bdeltadisc(ix,idisc) ...
                                    + jacobian(this.sym.bf(ix,idisc),this.strsym.xBs)*N(ix,:);
                            end
                        end
                    end
                end
                
            case 'sdeltadisc'
                syms foo
                
                this.sym.sdeltadisc = sym(zeros(nx,np,ndisc));
                this.sym.sf = sym(zeros(nx,np,ndisc));
                this.sym.sv = sym(zeros(nx,np,ndisc));
                this.sym.sw = sym(zeros(nx,np,ndisc));
                this.sym.sz = sym(zeros(nx,np,ndisc));
                
                if(ndisc>0)
                    for ix = 1:nx
                        for ip = 1:np
                            tmp_str_d = char(this.sym.sxdot(ix,ip));
                            idx_start_d = strfind(tmp_str_d,'dirac' ) + 5 ;
                            summand_ignore = [];
                            
                            if(~isempty(idx_start_d))
                                for iocc_d = 1:length(idx_start_d)
                                    brl = 1; % init bracket level
                                    str_idx_d = idx_start_d(iocc_d); % init string index
                                    % this code should be improved at some point
                                    while brl >= 1 % break as soon as initial bracket is closed
                                        str_idx_d = str_idx_d + 1;
                                        if(strcmp(tmp_str_d(str_idx_d),'(')) % increase bracket level
                                            brl = brl + 1;
                                        end
                                        if(strcmp(tmp_str_d(str_idx_d),')')) % decrease bracket level
                                            brl = brl - 1;
                                        end
                                    end
                                    idx_end_d = str_idx_d;
                                    arg_d = tmp_str_d((idx_start_d(iocc_d)+1):(idx_end_d-1));
                                    if(strfind(arg_d,',')) % higher order derivatives
                                        if(regexp(tmp_str_d((idx_start_d(iocc_d)):(idx_start_d(iocc_d)+2)),'\([1-2],'))
                                            arg_d = tmp_str_d((idx_start_d(iocc_d)+3):(idx_end_d-1));
                                        elseif(regexp(tmp_str_d((idx_end_d-3):(idx_end_d)),', [1-2])'))
                                            arg_d = tmp_str_d((idx_start_d(iocc_d)+1):(idx_end_d-4));
                                        end
                                    end
                                    str_arg_d = ['dirac(' char(sym(arg_d)) ')' ]; % the char(sym(...)) hopefully ensures consistent ordering of the argument
                                    str_arg_d1 = ['dirac(1, ' char(sym(arg_d)) ')' ]; % the char(sym(...)) hopefully ensures consistent ordering of the argument
                                    str_arg_1d = ['dirac(' char(sym(arg_d)) ', 1)' ]; % the char(sym(...)) hopefully ensures consistent ordering of the argument
                                    str_arg_d2 = ['dirac(2, ' char(sym(arg_d)) ')' ]; % the char(sym(...)) hopefully ensures consistent ordering of the argument
                                    str_arg_2d = ['dirac(' char(sym(arg_d)) ', 2)' ]; % the char(sym(...)) hopefully ensures consistent ordering of the argument
                                    dotarg_d = diff(sym(arg_d),'t') + jacobian(sym(arg_d),this.strsym.xs)*this.sym.xdot;
                                    % find the corresponding discontinuity
                                    % xdot_i = f_i(x,t) + v_i*delta(t-t0) +
                                    % w_i*delta(1)(t-t0) + z_i*delta(t-t0);
                                    for idisc = 1:ndisc;
                                        if(isequaln(abs(sym(arg_d)),abs(this.sym.rdisc(idisc))))
                                            if(length(children(this.sym.sxdot(ix,ip)+foo))==2) % if the term is not a sum
                                                summands = this.sym.sxdot(ix,ip);
                                            else
                                                summands = children(this.sym.sxdot(ix,ip));
                                            end
                                            for is = 1:length(summands)
                                                if(isempty(find(is==summand_ignore,1))) % check if we already added that term
                                                    str_summand = char(summands(is));
                                                    if(strfind(str_summand,str_arg_d)) % v_i
                                                        this.sym.sv(ix,ip,idisc) = this.sym.sv(ix,ip,idisc) + sym(strrep(str_summand,str_arg_d,char(1/abs(dotarg_d))));
                                                        summand_ignore = [summand_ignore is];
                                                    elseif(strfind(str_summand,str_arg_d1)) % w_i
                                                        this.sym.sw(ix,ip,idisc) = this.sym.sw(ix,ip,idisc) ...
                                                            + sym(strrep(str_summand,str_arg_d1,char(dotarg_d/abs(dotarg_d))));
                                                        summand_ignore = [summand_ignore is];
                                                    elseif(strfind(str_summand,str_arg_1d)) % w_i
                                                        this.sym.sw(ix,ip,idisc) = this.sym.sw(ix,ip,idisc) ...
                                                            + sym(strrep(str_summand,str_arg_1d,char(dotarg_d/abs(dotarg_d))));
                                                        summand_ignore = [summand_ignore is];
                                                    elseif(strfind(str_summand,str_arg_d2)) % z_i
                                                        this.sym.sz(ix,ip,idisc) = this.sym.sz(ix,ip,idisc) ...
                                                            + sym(strrep(str_summand,str_arg_d2,char(dotarg_d^2/abs(dotarg_d))));
                                                        summand_ignore = [summand_ignore is];
                                                    elseif(strfind(str_summand,str_arg_2d)) % z_i
                                                        this.sym.sz(ix,ip,idisc) = this.sym.sz(ix,ip,idisc) ...
                                                            + sym(strrep(str_summand,str_arg_2d,char(dotarg_d^2/abs(dotarg_d))));
                                                        summand_ignore = [summand_ignore is];
                                                    else % f
                                                        this.sym.sf(ix,ip,idisc) = this.sym.sf(ix,ip,idisc) + summands(is);
                                                        summand_ignore = [summand_ignore is];
                                                    end
                                                end
                                            end
                                        else
                                            this.sym.sf(ix,ip,idisc) = this.sym.sxdot(ix,ip);
                                        end
                                    end
                                end
                            else
                                this.sym.sf(ix,ip,:) = repmat(this.sym.sxdot(ix,ip),[1,1,ndisc]);
                            end
                        end
                    end
                    % compute sdeltadisc
                    for idisc = 1:ndisc
                        nonzero_z = any(this.sym.z(:,idisc)~=0);
                        if(nonzero_z)
                            M = jacobian(this.sym.xdot(:,idisc),this.strsym.xs)*this.sym.z(:,idisc) ...
                                + this.sym.w(:,idisc) ...
                                - diff(this.sym.z(:,idisc),'t') - jacobian(this.sym.z(:,idisc),this.strsym.xs)*this.sym.xdot;
                        else
                            M = this.sym.w(:,idisc);
                        end
                        nonzero_M = any(M~=0);
                        for ip = 1:np
                            nonzero_sz = any(this.sym.sz(:,ip,idisc)~=0);
                            if(nonzero_z)
                                if(nonzero_sz)
                                    N = jacobian(this.sym.sf(:,ip,idisc),this.strsym.xs)*this.sym.z(:,idisc) ...
                                        + jacobian(this.sym.sf(:,ip,idisc),this.strsym.sx(:,ip))*this.sym.sz(:,ip,idisc) ...
                                        + this.sym.sw(:,ip,idisc) ...
                                        - diff(this.sym.sz(:,ip,idisc),'t') - jacobian(this.sym.sz(:,ip,idisc),this.strsym.xs)*this.sym.xdot ...
                                        - jacobian(this.sym.sz(:,ip,idisc),this.strsym.sx(:,ip))*this.sym.sxdot(:,ip);
                                else
                                    N = jacobian(this.sym.sf(:,ip,idisc),this.strsym.xs)*this.sym.z(:,idisc) ...
                                        + this.sym.sw(:,ip,idisc);
                                end
                            else
                                if(nonzero_sz)
                                    N = + jacobian(this.sym.sf(:,ip,idisc),this.strsym.sx(:,ip))*this.sym.sz(:,ip,idisc) ...
                                        + this.sym.sw(:,ip,idisc) ...
                                        - diff(this.sym.sz(:,ip,idisc),'t') - jacobian(this.sym.sz(:,ip,idisc),this.strsym.xs)*this.sym.xdot ...
                                        - jacobian(this.sym.sz(:,ip,idisc),this.strsym.sx(:,ip))*this.sym.sxdot(:,ip);
                                else
                                    N = this.sym.sw(:,ip,idisc);
                                end
                            end
                            nonzero_N = any(N~=0);
                            for ix = 1:nx
                                % delta_x_i =
                                % sum_j(df_idx_j*(sum_k(df_idx_k*z_k) +
                                % w_j - dot{z}_j) + v_i - dot{w}_i +
                                % ddot{z}_i
                                if(this.sym.sz(ix,ip,idisc)~=0)
                                    dszdx = jacobian(this.sym.sz(ix,ip,idisc),this.strsym.xs);
                                    dszdsxdot = jacobian(this.sym.sz(ix,ip,idisc),this.strsym.sx(:,ip));
                                    
                                    this.sym.sdeltadisc(ix,ip,idisc) = this.sym.sdeltadisc(ix,ip,idisc) ...
                                        + diff(this.sym.sz(ix,ip,idisc),'t',2) ...
                                        + diff(dszdx*this.sym.xdot,'t') ...
                                        + diff(dszdsxdot*this.sym.sxdot(:,ip),'t') ...
                                        + jacobian(dszdx*this.sym.xdot,this.strsym.xs)*this.sym.xdot ...
                                        + jacobian(dszdx*this.sym.xdot,this.strsym.sx(:,ip))*this.sym.sxdot(:,ip) ...
                                        + jacobian(dszdsxdot*this.sym.sxdot(:,ip),this.strsym.xs)*this.sym.xdot ...
                                        + jacobian(dszdsxdot*this.sym.sxdot(:,ip),this.strsym.sx(:,ip))*this.sym.sxdot(:,ip);
                                end
                                
                                if(this.sym.sv(ix,ip,idisc)~=0)
                                    this.sym.sdeltadisc(ix,ip,idisc) = this.sym.sdeltadisc(ix,ip,idisc) ...
                                        + this.sym.sv(ix,ip,idisc);
                                end
                                
                                if(this.sym.sw(ix,ip,idisc)~=0)
                                    this.sym.sdeltadisc(ix,ip,idisc) = this.sym.sdeltadisc(ix,ip,idisc) ...
                                        - diff(this.sym.sw(ix,ip,idisc),'t') - jacobian(this.sym.sw(ix,ip,idisc),this.strsym.xs)*this.sym.xdot ...
                                        - jacobian(this.sym.sw(ix,ip,idisc),this.strsym.sx(:,ip))*this.sym.sxdot(:,ip);
                                    
                                end
                                
                                if(nonzero_M)
                                    this.sym.sdeltadisc(ix,ip,idisc) = this.sym.sdeltadisc(ix,ip,idisc) ...
                                        + jacobian(this.sym.sf(ix,ip,idisc),this.strsym.xs)*M;
                                end
                                if(nonzero_N)
                                    this.sym.sdeltadisc(ix,ip,idisc) = this.sym.sdeltadisc(ix,ip,idisc) ...
                                        + jacobian(this.sym.sf(ix,ip,idisc),this.strsym.sx(:,ip))*N;
                                end
                            end
                        end
                    end
                    if(isfield(this,'this.nxtrue'))
                        for ip = 1:np
                            this.sym.sdeltadisc(:,ip,:) = mysubs(this.sym.sdeltadisc(:,ip,:),this.strsym.sx(this.rt(1:this.nxtrue),ip),this.strsym.xs(this.rt((1:this.nxtrue)+this.nxtrue*ip)));
                        end
                    end
                end
                
            case 'root'
                
                if(ndisc>0)
                    if(isempty(this.sym.root));
                        this.sym.root = this.sym.rdisc;
                    else
                        this.sym.root = [this.sym.root;this.sym.rdisc];
                    end
                end
            otherwise
        end
        this.fun.(funstr) = 1;
    else
        this.fun.(funstr) = 0;
    end
    
end