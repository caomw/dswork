% Author: Carl Doersch (cdoersch at cs dot cmu dot edu)
function [savestate respath]=dssavefield(f,fnam,basedir,currpath,savestate,brakidx,task,checksaves,mapsave,pathprefix)
global ds;
%currpath and savestate are for the parent directory/struct of the target field
respath={};
dochmod=0;
%is_hn45=dshasprefix(currpath,'/nfs/hn45/');
%is_lnobkp=dshasprefix(currpath,'/nfs/ladoga_no_backups');
%is_ssh=is_hn45||is_lnobkp;
modulo=1;
try
%  if(~isstruct(savestate))
%    savestate=struct();
%  end
%  nams=fieldnames(currds);
%  for(i=1:numel(nams))
%    clear filenm;
%    fnam=nams{i};
%    f=getfield(currds,fnam);
%    if(isstruct(f))
%      if(~isfield(savestate,fnam)||(isfield(getfield(savestate,fnam),'savestate')&&getfield(getfield(savestate,fnam),'savestate')==0))
%        mymkdir([currpath '/' fnam]);
%      end
%      if(~isfield(savestate,fnam))
%        savestate=setfield(savestate, fnam, dssave_rec(f,basedir,[currpath '/' fnam],struct(),movesonly));
%      else
%        savestate=setfield(savestate, fnam, dssave_rec(f,basedir,[currpath '/' fnam],getfield(savestate,fnam),movesonly));
%      end
    global ds;
    if(iscell(f))
      odirnm=[currpath '/' fnam '[]'];
        mapsave
      if(mapsave)
        if(dsfield(ds,'sys','distproc','localdir'))
          odirnm(1:numel(ds.sys.outdir))=[];
          %odirnm=strrep(odirnm,'\','\\');
          odirnm=strrep(odirnm(2:end),'/','.');
          odirnm=[ds.sys.distproc.localdir odirnm];
          if(dsfield(ds,'sys','distproc','reducehosts'))
            modulo=numel(ds.sys.distproc.reducehosts);
          end
        else
          mapsave=0
        end
      end

      %if(isfield(savestate,fnam)&&iscell(getfield(savestate,fnam))&&ischar(getfield(savestate,fnam)))
      %end
      %if(strcmp(fnam,'resimg'))
      %  keyboard;
      %end
      fnam
      savestate
      if(~isfield(savestate,fnam)||(numel(getfield(savestate,fnam))==0))
        %mymkdir(dirnm);
        folderstatus=0;
        marks=[];
      else
        marks=getfield(savestate,fnam);
        folderstatus=marks{1};
        marks=marks{2};
      end
      %if(~iscell(marks))
      %  if((numel(marks)==0)||(sum(marks)==0))
      %    folderstatus=0;
      %  else
      %    folderstatus=1;
      %  end
      %else
      %end
      %if(ischar(folderstatus))
      %  movefile([basedir '/' folderstatus ],dirnm);
      %  folderstatus=1;
      %end
      %if(~movesonly)
        if(numel(folderstatus)==1&&folderstatus==0)
          if(strcmp(task,'savedistr'))
            ds.sys.saved=[ds.sys.saved; {[pathprefix '.' fnam],{}}];
            respath=[respath; {[pathprefix '.' fnam],{}}];
          end
          if(~mapsave)
            mymkdir(odirnm);
          end
          folderstatus=1;
        end
        %marks2(1:numel(marks))=marks(:);
        %if(iscell(marks))
        %  marks2(1:numel(marks),1)=marks(:);
        %else
          %marks2(1:numel(marks),1)=marks(:);%mat2cell(marks(:),ones(numel(marks),1),1);
        %end
        %marks2=marks;
        %mustsave=0;
        %for(i=numel(marks2):-1:1)
        %  if(isempty(marks2(i))||marks2(i)~=1)
        %    mustsave=1;
        %    break;
        %  end
        %end
      if(dshassuffix(fnam,'img'))
        isimg=1;
      else
        isimg=0;
      end
      ispng=dshassuffix(fnam,'png');
      if(dshassuffix(fnam,'fig'))
        isfig=1;
      else
        isfig=0;
      end
      if(dshassuffix(fnam,'html'))
        ishtml=1;
      else
        ishtml=0;
      end
      if(dshassuffix(fnam,'txt'))
        istxt=1;
      else
        istxt=0;
      end
      marks2=false(size(f));
      if(~isempty(marks))
        marks2(1:size(marks,1),1:size(marks,2))=marks;
      end
      %if(mustsave)
      %disp(['got ' fnam]);
      if((ispng||isimg||isfig||ishtml)&&size(f,1)>1)
        disp(['warning: converting ' fnam ' to a row vector']);
        f=f(:)';
      end
      for(dssf_k=1:2)
        if(isempty(brakidx{dssf_k}))
          brakidx{dssf_k}=int32(1:size(f,dssf_k));
          if(isempty(brakidx{dssf_k}))
            %input was empty; nothing to do
            return
          end
        else
          brakidx{dssf_k}=brakidx{dssf_k}(brakidx{dssf_k}<=size(f,dssf_k));
        end
      end
      if(ispng||isimg||isfig||ishtml||istxt)
        %for(i=brakidx{1}(:)')
        %  dssf_k=dssf_k+1;
        %  dirnm=[odirnm '/' num2str(i)];
        %  if(any((~marks2(i,brakidx{2}))|(~fisempty(dssf_k,:))))
        %    mymkdir(dirnm);
        %  end
        ntosave=sum(sum(~marks2(brakidx{2})));
        ntotal=numel(marks2);
        chmodeach=(ntosave/ntotal)<.05;
        %fisempty=cellfun(@(x) isempty(x),f(brakidx{2}));
        fisempty=[];%logical(zeros(1,brakidx{2}));
        %for(i=numel(brakidx{2}):-1:1)
        %  fisempty(i)=isempty(f{brakidx{2}(i)});
        %end
        fisempty=cellfun(@isempty,f(brakidx{2}));
        dssf_l=0;
        dssf_k=1;
        i=1;
        dirnm=odirnm;%we used to support 2d cell arrays, but they were useless
        if(strcmp(task,'savedistr'))
          indstmp=brakidx{2}(find((~marks2(brakidx{2}(:)))&(~fisempty(dssf_k,:))));
          if(~isempty(indstmp))
            ds.sys.saved=[ds.sys.saved;{[pathprefix '.' fnam],indstmp(:)}];
            respath=[respath;{[pathprefix '.' fnam],indstmp(:)}];
          end
        end
          dssf_inds=find(~fisempty(dssf_k,:));

          for(dssf_l=dssf_inds)%j=brakidx{2}(:)')
            j=brakidx{2}(dssf_l);
            %dssf_l=dssf_l+1;
            %if((marks2(i,j)~=1)&&(~fisempty(dssf_k,dssf_l)))
              if(isimg)
                filenm=[dirnm '/' num2str(j) '.jpg'];
                imwrite(f{i,j},filenm,'Quality',95);
              elseif(ispng)
                filenm=[dirnm '/' num2str(j) '.png'];
                dssavepng(f{i,j},filenm);
              elseif(isfig)
                set(f{i,j},'Position',[5 5 960 600]);
                filenm2=[dirnm '/' num2str(j) '.pdf'];
                filenm=[dirnm '/' num2str(j) '.jpg'];
                  dssavefig(f{i,j},filenm,filenm2);
                  if(dochmod&&chmodeach)
                      unix(['chmod 755 ' filenm2]);
                  end
              elseif(ishtml||istxt)
                if(ishtml)
                  filenm=[dirnm '/' num2str(j) '.html'];
                else
                  dotpos=find(dfnam=='_');
                  type=varnm((dotpos(end)+1):end);
                  filenm=[dirnm '/' num2str(j) type(1:end-3)];
                end
                fptr=fopen(filenm,'w');
                fprintf(fptr,f{i,j});
                fclose(fptr);
              end
              marks2(1,j)=true;
              if(exist('filenm','var')&&dochmod&&chmodeach)
                unix(['chmod 755 ' filenm]);
              end
            %end
          end
        %end
        if(dochmod&&(~chmodeach))
          unix(['chmod -R 755 ' dirnm]);
        end
      else
        ntosave=sum(sum(~marks2(brakidx{1},brakidx{2})));
        ntotal=numel(marks2);
        chmodeach=(ntosave/ntotal)<.05;
        %fisempty=cellfun(@(x) isempty(x),f(brakidx{1},brakidx{2}));
        fnosv=(marks2(brakidx{1},brakidx{2}));%(zeros(brakidx{1},brakidx{2})>0);
        fnosv=fnosv|cellfun(@isempty,f(brakidx{1},brakidx{2}));
        %tic
        %for(i=numel(brakidx{2}):-1:1)
        %  for(j=numel(brakidx{1}):-1:1)
        %    fnosv(j,i)=(fnosv(j,i)||isempty(f{brakidx{1}(j),brakidx{2}(i)}));
        %  end
        %end
        %toc
        if(all(fnosv))
          return;
        end
        dssf_k=0;
        hassaved=0;
        %distsavedinds=zeros(sum(fnosv(:)==0),2);
        [brakidxposrow brakidxposcol]=find(~fnosv);
        brakidxposrow=brakidx{1}(brakidxposrow);
        brakidxposcol=brakidx{2}(brakidxposcol);
        distsavedinds=[brakidxposrow(:) brakidxposcol(:)];
        if(strcmp(task,'savedistr')&&(~isempty(distsavedinds)))
          ds.sys.saved=[ds.sys.saved;{[pathprefix '.' fnam],distsavedinds}];
          respath=[respath;{[pathprefix '.' fnam],distsavedinds}];
        end
        if(mapsave&&dsbool(ds.sys.distproc,'mapreducer'))
          waitfifo = [ds.sys.distproc.localdir 'waitfifo' num2str(ds.sys.distproc.mapreducerid)];
          isfirstsend=1;
          %unix(['mkfifo ' waitfifo]);
        end
        svcols=~all(fnosv,1);
        brakidx{2}=brakidx{2}(svcols);
        fnosv=fnosv(:,svcols);
        for(i=brakidx{2}(:)')
          dssf_k=dssf_k+1;
          %dirnm=[odirnm '/' num2str(i)];
          %if(any((~marks2(brakidx{1},i))|(~fisempty(:,dssf_k))))
          %  mymkdir(odirnm);
          %end
          dssf_l=0;
          v73switch=[];
          if(size(marks,2)>=i&&any(marks(:,i)))
            appendswitch={'-append'};
          else
            appendswitch=[];
          end
          varstosave={};
          indstosave=[];
          for(j=brakidx{1}(:)')
            dssf_l=dssf_l+1;
            if((fnosv(dssf_l,dssf_k)==0))
                %addtodistsave=[j,i];
                %distsavedinds(distsavedindsidx,:)=[j,i];
                %distsavedindsidx=distsavedindsidx+1;
                %if(ischar(marks2{i}))
                %  movefile([basedir '/' marks2{i} '.mat'],filenm);
                %  marks2{i}=1;
                %elseif(~movesonly)
                  snm=['data' num2str(j)];
                  %eval([snm '=f{j,i};']);
                  savedata{j}=f{j,i};
                  %s=whos(snm);
                  %if([s.bytes]>=1000000000)
                    %in my experience, -v7.3 is less stable, so only 
                    %use it when really necessary
                    v73switch={'-v7.3'};
                    %save(filenm,'data','-v7.3');
                  %end
                  %if(numel(varstosave)>1)
                  %  varstosave=[varstosave ',''' snm ''''];
                  %else
                  %  varstosave=['''' snm ''''];
                  %end
                  varstosave{j}=snm;
                  indstosave=[indstosave j];
                %  marks2{i}=1;
                %end
              marks2(j,i)=true;
              %disp(j)
              %keyboard;
            end
            if(mod(i,10000)==0)
              disp(i)
            end
          end
          if(mapsave)%don't have everyone send to the same machine at the same time
            [~,startidx]=ismember(ds.sys.distproc.myhost,ds.sys.distproc.reducehosts);
            if(startidx==0)
              startidx=1+floor(rand*numel(ds.sys.distproc.reducehosts));
            end
            rng=[startidx:modulo, 1:startidx-1];
          else
            rng=1:modulo;
          end
          for(k=rng)
            if(mapsave)
              filenm=[odirnm '~' num2str(i) '~' num2str(k) '.mat'];
            else
              filenm=[odirnm '/' num2str(i) '.mat'];
            end
            if(numel(varstosave)>0)
              contents=[];
              if(length(appendswitch)>0)
                load(filenm,'contents');
              end
              contents=union(contents,indstosave(k:modulo:end));
              %keyboard;
              tic
              currvarstosave=varstosave(k:modulo:end);
              currsavedata=[{contents} savedata(k:modulo:end)];
              for(m=numel(currvarstosave):-1:1)
                if(isempty(currvarstosave{m}))
                  currvarstosave(m)=[];
                  currsavedata(m+1)=[];
                end
              end
              varnms=[{'contents'} currvarstosave];
              args=[appendswitch v73switch];
              %args=[{'contents'} currvarstosave appendswitch v73switch];
              checkpassed=0;
              while(~checkpassed)
                tic
                s1=cell2struct(currsavedata,varnms,2);
                save(filenm,'-struct','s1',args{:});
                toc
                checkpassed=(~checksaves)||checksave(filenm,varstosave);
              end
              if(mapsave&&dsbool(ds.sys.distproc,'mapreducer'))
                if(~isfirstsend)
                  a=tic
                  %unix(['a=`head -n 1 ' waitfifo '`']);
                  disp(['fifowait' num2str(toc(a))]);
                end
                isfirstsend=0;
                sendfile(filenm,ds.sys.distproc.reducehosts{k},ds.sys.distproc.myhost,waitfifo);
              end
              if(~isempty(currvarstosave))
                clear(currvarstosave{:});
              end
              clear contents;
              toc
              hassaved=1;
              if(exist('filenm','var')&&dochmod&&chmodeach)
                unix(['chmod 755 ' filenm]);
              end
            end
          end
        end
        %if(mapsave&&dsbool(ds.sys.distproc,'mapreducer'))
          %unix(['a=`head -n 1 ' waitfifo '`']);
          %unix(['rm ' waitfifo]);
        %end
        if((~chmodeach)&&dochmod&&hassaved)
          unix(['chmod -R 755 ' odirnm]);
        end
      end
      %end
        %marks2=ones(size(marks2));
      %else
      %  marks2=marks;
      %end
      savestate=setfield(savestate,fnam,{folderstatus,marks2});%mat2cell(ones(size(marks2)),ones(numel(marks2),1),1));
      if(folderstatus==1&&~mapsave&&~exist(odirnm,'dir'))
        'savestate thinks a folder exists, but it doesn''t--did you modify anything on the filesystem?'
        keyboard;
      end
    else
      %check if we have anything to do.  seems like there must be a better way...
      if(~isfield(savestate,fnam)||ischar(getfield(savestate,fnam))||isempty(getfield(savestate,fnam))||~(getfield(savestate,fnam)==1))
        if(strcmp(task,'savedistr'))
          ds.sys.saved=[ds.sys.saved;{[pathprefix '.' fnam],[]}];
        end
        respath=[respath;{fnam,[]}];
        filenm=dsgetdisknam(f,fnam,[currpath '/']);
        %if(isfield(savestate,fnam)&&ischar(getfield(savestate,fnam)))
        %  mvnam=getfield(savestate,fnam);
        %else
        %  mvnam=[];
        %end
        %disp(['got ' fnam]);
        if(dshassuffix(fnam,'img')||dshassuffix(fnam,'png'))
          %filenm=[currpath '/' fnam '.jpg']; 
          %if(~isempty(mvnam))
          %  movefile([basedir '/' mvnam '.jpg'],filenm);
          %  savestate=setfield(savestate,fnam,1);
          %elseif(~movesonly)
          if(dshassuffix(fnam,'png'))
            dssavepng(f,filenm{1});
          else
            imwrite(f,filenm{1});
          end
            savestate=setfield(savestate,fnam,true);
          %end
        elseif(dshassuffix(fnam,'html') || dshassuffix(fnam,'txt'))
          %filenm=[currpath '/' fnam '.html'];
          %if(~isempty(mvnam))
          %  movefile([basedir '/' mvnam '.html'],filenm);
          %  savestate=setfield(savestate,fnam,1);
          %elseif(~movesonly)
            fptr=fopen(filenm{1},'w');
            fprintf(fptr,f);
            %fprintf(fptr,'%s',f);
            fclose(fptr);
            savestate=setfield(savestate,fnam,true);
          %end
        elseif(dshassuffix(fnam,'fig'))
            %set(f,'Position',[5 5 960 600]);
          %filenm2=[currpath '/' fnam '.jpg'];
          %filenm=[currpath '/' fnam '.pdf'];
          %if(~isempty(mvnam))
          %  movefile([basedir '/' mvnam '.jpg'],filenm2);
          %  movefile([basedir '/' mvnam '.pdf'],filenm);
          %  savestate=setfield(savestate,fnam,1);
          %elseif(~movesonly)
            dssavefig(f,filenm{1},filenm{2});
            savestate=setfield(savestate,fnam,true);
          %end

            %oldscreenunits = get(f,'Units');
            %oldpaperunits = get(f,'PaperUnits');
            %oldpaperpos = get(f,'PaperPosition');
            %set(f,'Units','pixels');
            %scrpos = get(f,'Position')
            %newpos = scrpos/100;
            %set(f,'PaperUnits','inches',...
            %'PaperPosition',newpos)
            %drawnow
            %print(f,'-djpeg',filenm,'-r100');
            %print(f,'-dpdf',filenm2,'-r100');
            %export_fig(filenm2,f);
            if(dochmod)
              unix(['chmod 755 ' filenm2]);
            end
            %set(f,'Units',oldscreenunits,...
            %'PaperUnits',oldpaperunits,...
            %'PaperPosition',oldpaperpos)
          %filenm=[currpath '/' fnam '.jpg'];
          %print(f,'-djpeg',filenm);
        else
          %filenm=[currpath '/' fnam '.mat'];
          %if(~isempty(mvnam))
          %  movefile([basedir '/' mvnam '.mat'],filenm);
          %  savestate=setfield(savestate,fnam,1);
          %elseif(~movesonly)
            data=f;
            s=whos('data');
            if([s.bytes]>=1000000000)
               %in my experience, -v7.3 is less stable, so only 
               %use it when really necessary
               save(filenm{1},'data','-v7.3');
            else
              save(filenm{1},'data');
            end
            savestate=setfield(savestate,fnam,true);
          %end
        end
      end
      if(dochmod&&exist('filenm','var'))
        unix(['chmod 755 ' filenm{1}]);
      end
    end
%  end
catch ex
dsprinterr
end
end
function res=checksave(fname,vars)
  res=true;
  try
    eval(['load(''' fname ''',' vars ');']);
    disp('save check passed');
  catch ex
    dsstacktrace(ex);
    res=false;
  end
  eval(['clear(' vars ');']);
end

function sendfile(fnam,targhost,myhost,waitfifo)
  global ds;
  disp(['sending ' fnam ' to ' targhost ' from ' myhost])
  if(strcmp(myhost,targhost))
    return;
  end
  fnamsh=fnam(1:end-1);
  fnamsh(end-1:end)='sh';
  fid=fopen(fnamsh,'w');
  %fnam=strrep(fnam,'\','\\');
  %fnamsh=strrep(fnamsh,'\','\\');
  fprintf(fid,['code=1\n']);%set $? to 1
  fprintf(fid,['waittime=2\n']);%set $? to 1
  fprintf(fid,['while [ $code -gt "0" ] ; do \n']);
  fprintf(fid,['time scp -F "' ds.sys.distproc.sshconf '" "' fnam '" "' targhost ':' fnam '"\n']); 
  fprintf(fid,['code=$?\n']);
  fprintf(fid,['if [ $code -gt "0" ] ; then echo "fail"; sleep $waittime ; waittime=$(expr $waittime "*" 3 / 2) ; fi\n']);
  fprintf(fid,['done\n\n']);
  %fprintf(fid,['?=1\n']);
  %fprintf(fid,['while [ "$?" -gt "0" ] ; do time ssh ' targhost ' mv "' fnam '_tmp" "' fnam '"; done\n']);
  %fprintf(fid,['echo "" > "' waitfifo '"\n']);
  fprintf(fid,['rm "' fnam '"\n']);
  fprintf(fid,['rm "' fnamsh '"\n']);
  fclose(fid);
  unix(['chmod 700 ' fnamsh]);
  %error('fail');
  tic
  %unix([fnamsh ' > ' fnamsh '.log 2>&1']);
  %unix([fnamsh ' &']);
  unix([fnamsh]);
  toc
end
