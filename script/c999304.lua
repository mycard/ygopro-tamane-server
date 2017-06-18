--寂寞与终焉的象征
function c999304.initial_effect(c)
	c:EnableReviveLimit()
	-- xyzop
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_EXTRA)
	e1:SetCondition(c999304.xyzcon)
	e1:SetOperation(c999304.xyzop)
	e1:SetValue(SUMMON_TYPE_XYZ)
	c:RegisterEffect(e1)
	--atk down
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(999304,0))
	e2:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCountLimit(1)
	e2:SetTarget(c999304.target)
	e2:SetOperation(c999304.operation)
	c:RegisterEffect(e2)
	--limit
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_HAND_LIMIT)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(1,1)
	e3:SetValue(c999304.limitval)
	c:RegisterEffect(e3)
	--damage
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_LEAVE_FIELD)
	e4:SetRange(LOCATION_MZONE)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)	
	e4:SetTarget(c999304.tg2)
	e4:SetOperation(c999304.op2)
	c:RegisterEffect(e4)
end

c999304.xyz_count = 2

function c999304.selffilter(c,tc)
	return c==tc
end

function c999304.tokenfilter(c)
	return c:IsType(TYPE_TOKEN) and c:IsRace(RACE_PLANT) and c:IsReleasable() and c:IsLevelBelow(2)
end
function c999304.mfilter(c,xyzc)
	return c:IsRace(RACE_PLANT) and c:IsXyzLevel(xyzc,2)
end
function c999304.xyzcheck(g,xyzc,exg)
	local ct=g:GetCount()
	return g:CheckWithSumEqual(c999304.val(exg),4,ct,ct)
end
function c999304.val(exg)
	return 	function(c)
				return exg:IsContains(c) and c:GetLevel() or 2
			end
end
function c999304.xyzcon(e,c,og,min,max)
	if c==nil then return true end
	if c:IsType(TYPE_PENDULUM) and c:IsFaceup() then return false end
	local tp=c:GetControler()
	local func=c999304.mfilter
	local gf=c999304.xyzcheck
	local ext_params={}
	local minc=2
	local maxc=4
	if min then
		minc=math.max(minc,min)
		maxc=math.min(maxc,max)
	end
	local mg=nil
	local exg=Group.CreateGroup()
	if og then
		mg=og:Filter(Nef.XyzProcedureCustomFilter,nil,c,func,ext_params)
		exg=og:Filter(c999304.tokenfilter,nil)
	else
		mg=Duel.GetMatchingGroup(Nef.XyzProcedureCustomFilter,tp,LOCATION_MZONE,0,nil,c,func,ext_params)
		exg=Duel.GetMatchingGroup(c999304.tokenfilter,tp,LOCATION_MZONE,0,nil)
		mg:Merge(exg)
	end
	return maxc>=minc and Nef.CheckGroup(mg,Nef.CheckFieldFilter,nil,minc,maxc,tp,c,gf,c,exg)
end
function c999304.xyzop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=nil
	local exg=Group.CreateGroup()
	if og and not min then
		g=og
	else
		local func=c999304.mfilter
		local gf=c999304.xyzcheck
		local ext_params={}
		local mg=nil

		if og then
			mg=og:Filter(Nef.XyzProcedureCustomFilter,nil,c,func,ext_params)
			exg=og:Filter(c999304.tokenfilter,nil)
		else
			mg=Duel.GetMatchingGroup(Nef.XyzProcedureCustomFilter,tp,LOCATION_MZONE,0,nil,c,func,ext_params)
			exg=Duel.GetMatchingGroup(c999304.tokenfilter,tp,LOCATION_MZONE,0,nil)
			mg:Merge(exg)
		end
		local minc=2
		local maxc=4
		if min then
			minc=math.max(minc,min)
			maxc=math.min(maxc,max)
		end
		g=Nef.SelectGroup(tp,HINTMSG_XMATERIAL,mg,Nef.CheckFieldFilter,nil,minc,maxc,tp,c,gf,c,exg)
	end
	c:SetMaterial(g)
	local rg=g:Filter(function(c) return exg:IsContains(c) end,nil)
	g:Sub(rg)
	Duel.Release(rg,REASON_COST+REASON_MATERIAL)
	Nef.OverlayGroup(c,g,false,true)
end

function c999304.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsFaceup() and chkc:GetLocation()==LOCATION_MZONE end
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
end

function c999304.operation(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	local c=e:GetHandler()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetReset(RESET_EVENT+0x1fe0000+RESET_PHASE+PHASE_END)
		e1:SetValue(tc:GetBaseAttack()/2)
		tc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_SET_DEFENSE_FINAL)
		e2:SetReset(RESET_EVENT+0x1fe0000+RESET_PHASE+PHASE_END)
		e2:SetValue(tc:GetBaseDefense()/2)
		tc:RegisterEffect(e2)
	end
end

function c999304.limitval(e)
	return e:GetHandler():GetOverlayCount()+2
end

function c999304.tg2(e,tp,eg,ep,ev,re,r,rp,chk)
	return eg:IsExists(Card.IsRace,1,nil,RACE_PLANT)
end

function c999304.op2(e,tp,eg,ep,ev,re,r,rp)
	local lp=Duel.GetLP(1-tp)
	if lp>300 then 
		lp=lp-300
	else 
		lp=0 
	end

	Duel.SetLP(1-tp,lp)
end
