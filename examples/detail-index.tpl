{%strip%}
{%extends 'common/base_html_new.tpl'%}

{%block 'global_def'%}
	{%$is_myAsk = false%}
	{%$is_resolved = false%}
	{%$is_AskAuditOrDel = false%}
	{%$has_best = false%}
	{%$has_myAnswer = false%}
	{%$has_recommend = false%}
	{%$can_be_ans = false%}
	{%$is_official_admin = false%}
	{%$normal_user = false%}

	{%if $user_info.role == 0%}{%$normal_user = true%}{%/if%}
	{%if $user_info.role == 5 || $user_info.role == 6%}
		{%$is_official_admin = true%}
	{%/if%}
	{%if $user_info.qid == $ask_info.qid%} {%$is_myAsk = true%} {%/if%}
	{%if !empty($my_answer) %} {%$has_myAnswer = true%} {%/if%}
	{%if !empty($best_answer_info)%} {%$has_best = true%} {%/if%}
	{%if !empty($recommend_answer_info)%} {%$has_recommend = true%} {%/if%}
	{%if $has_best || $has_recommend%} {%$is_resolved = true%} {%/if%}
	{%if $ask_info.status <= 3 || ($ask_info.status == 4 && !$is_myAsk && $is_nonlog_ask != 1)%}
		{%$is_AskAuditOrDel == true%}
	{%/if%}

	{%if !$ask_info.is_my_ask && !$is_resolved && !$has_myAnswer%}
		{%$can_be_ans = true%}
	{%/if%}

	{%$seo_desc = $ask_info.content|cat:" "%}

	{%if $has_best%}
		{%$seo_desc = $seo_desc|cat:$ask_info.best_answer_info.content%}
	{%else%}
		{%foreach $append_info.data[$ask_info.ask_id] as $item%}
			{%$seo_desc = $seo_desc|cat:" "|cat:$item.content%}
		{%/foreach%}

		{%foreach $answer_info.answer_list as $item%}
			{%$seo_desc = $seo_desc|cat:" "|cat:$item.content%}
			{%if $item@iteration > 10%}
				{%break%}
			{%/if%}
		{%/foreach%}
	{%/if%}

	{%$seo_desc = Utility::m_mbSubStr(str_replace(array('"',"&nbsp;")," ",trim(strip_tags($seo_desc))),600)%}

	{%if !$seo_desc%}
		{%$seo_desc = "未解决问题 等待您来回答 奇虎360旗下最大互动问答社区"%}
	{%/if%}

	{%* 春雨医生的数据 *%}
	{%if !empty($chunyu_data)%}
		{%$doctor_info = $chunyu_data.doctor_info%}
	{%/if%}

{%/block%}

{%block 'title' append%}{%$ask_info.title%}_{%$wdDomainInfo.wenda_name%}{%/block%}
{%block 'keywords' append%}{%$ask_info.title%}_{%$wdDomainInfo.wenda_name%}{%/block%}
{%block 'description'%}{%$ask_info.title%} {%$seo_desc%}{%/block%}

{%block 'header_js'%}
	{%*****
		monitor_etype: 定义企业统计的页面类型，详情页所有地方可调用
		window.monitorTrackDisabled = true: 详情页禁用自动发送PV统计，改为在detail/index.js里手工触发
	*****%}
	{%$monitor_etype = '网页详情页'%}
	<script type="text/javascript">
		$INFO['askId'] = "{%$ask_info.ask_id%}";
		$INFO['askTitle'] = "{%$ask_info.title%}";
		$INFO['askCid'] = "{%$ask_info.cid%}";/*问题当前分类*/
		$INFO['askCid1'] = "{%$ask_info.cid1%}";/*问题一级分类*/
		$INFO['askCid2'] = "{%$ask_info.cid2%}";/*问题二级分类，可能为0*/
		$INFO['isHide'] = "{%$ask_info.is_hide%}";
		$INFO['isResolved'] = "{%$is_resolved%}";
		$INFO['sid'] = "{%$sid%}";
		/*$INFO['isMyAsk'] = "{%$ask_info.is_my_ask%}";*/
		$INFO['realViews'] = "{%$ask_info.realviews%}";
		$INFO['askMid'] = "{%$ask_info.ext.mid%}";
		$INFO['askType'] = "{%$ask_info.ext.ask_type%}";
		$INFO['askTag'] = "{%if $ask_info.ext.tags%}{%$ask_info.ext.tags[0]%}{%/if%}";
		window.monitorTrackDisabled = true;
	</script>

{%/block%}

{%block 'page_css'%}
	<link rel="stylesheet" href="/resource/css/page/detail/detail.combo.css"/>
	{%if $show_bannerAd == 2 %}{%*底部广告列表css*%}
	<link rel="stylesheet" href="/resource/css/module/business/business_list.css"/>
	{%/if%}
{%/block%}

{%block 'page_js'%}
	{%*<!-- 地图脚本，脚本里面有write所以。。唉-->*%}
	<script src="http://map.{%$wdDomainInfo.root_domain%}/api/js"></script>
	<!--[if IE 6]><script>DD_belatedPNG.fix(".mod-music-add-toolbar span")</script><![endif]-->

	<script src="/resource/js/page/detail/detail.combo.js"></script>

	{%if $show_bannerAd == 2 %}{%*<!--底部广告列表js 利用js ajax请求向广告外壳添加内容-->*%}
		<script src="/resource/js/module/business/business_list.js"></script>
	{%/if%}
	{%*<!--通用服务性能打点-->*%}
	<script src="http://s0.qhres.com/static/61bc8925b74cf513.js"></script>
	<script>SoLog.init({pro:'wenda', pid:'detail'}).log();</script>
{%/block%}

{%block 'bd_attr'%} class="mod-detail" style="margin-top:16px;"{%/block%}

{%block 'content'%}
	{%*
	<!--
		点睛广告说明：2017.5.3
		新的广告接口整合了之前的接口，小流量上线需要abtest
		修改如下：
		1.右侧文字广告的两条由之前的直接拿到html，改成json数据，需要加样式
		2.左侧下面的文字广告去掉
		3.你可能感兴趣的内容由异步变成同步
		4."相关问题"的第一条放广告

		$businessAdNew.code 为-1 没有命中新接口
		$businessAdNew.code 为0 命中新接口，若ads没有数据，则虽命中却无广告

	-->
	*%}


	{%$busi_data = ""%}
	{%if $businessAdNew.code != "-1" && !empty($businessAdNew.data)%}
		{%$busi_data = $businessAdNew.data%}
	{%/if%}

	<input type="hidden" value="{%$ask_info.title%}" id="js-ask-title"/>

	{%*
	<!--
		date: 2015-08-31 11:09
		des: 商业广告部分，由于反作弊需要，需要在广告内容出现之前把广告相关的js加载完
			 这个里面有数据有时候返回的数据比较怪，为了不影响界面的显示。把它放在一个隐藏的区域里面
	-->
	*%}
	<div style="display:none;">
		{%*<!--2017.5.3 点睛，如果有新数据，则将新数据js放进去，如果没有新数据，看老数据里有没有-->*%}
		{%if !empty($busi_data)%}
			{%$busi_data.click_js%}
			{%$busi_data.pv_js%}
		{%/if%}
		
	</div>

	<!-- 面包屑导航 -->
	{%**include 'mod/common/cate_crumb_box.inc' tree=$cate_tree type="detail"**%}

	<!-- 右侧滚动新闻 -->
	{%**include 'cms/detail/today_news.inc'**%}

	<div style="clear:both"></div>
	{%if !$is_AskAuditOrDel%}
		<div class="grid clearfix">
			<!-- 填空回答，安仔提示  -->
			{%*************
			{%if $can_be_ans and $ask_info.ext.ask_type%}
			<div class="fill-tips">
				<div class="tips-desc">试试在答案后输入简单的回答结果，在下方进行详细的展开说明，会看到不一样的结果哦~
				</div>
				<i class="arrow"></i>
			</div>
			{%/if%}
			**************%}

			<div class="article {%if $is_resolved%}border-green{%/if%}" id="js-detail">
				{%* 头部广告位，只有已解决的问题有 *%}
				{%if $is_resolved%}
					{%include 'cms/detail/top_banner.inc'%}
				{%/if%}

				{%*<!-- 问题标题和描述 -->*%}
				{%include 'detail/part_question.inc'%}

				{%*<!-- 回答问题，包含编辑器 -->*%}
				{%include 'detail/part_ans_box.inc'
					show = $can_be_ans
					type = "0"
					sendURL = "/submit/answer"
				%}

				{%* 
				 * 注意 满意答案，推荐回答和精华回答的关系
				 * 1.使用高级编辑器回答并且被管理员推荐的答案叫做精华回答
				 * 2.普通回答框回答的并且被管理员推荐的答案叫做推荐回答
				 * 3.无论是普通回答框回答的还是高级编辑器回答的（也包括精华回答和推荐回答），一旦被用户采纳了叫做满意答案
				 * 4.问题已解决的情况有5种：满意答案，精华回答，推荐回答，满意答案+精华回答，满意答案+推荐回答
				 *%}

				{%*<!-- 满意答案 -->*%}
				{%include 'detail/part_resolved_ans.inc'
					show = $has_best
					_answer_info = $best_answer_info
					_type = "best"
				%}

				{%**<!-- 推荐答案包含推荐答案和精华答案 -->**%}
				{%if $recommend_answer_info.ext.essence%}
					{%$recom_type = "essence"%}
				{%else%}
					{%$recom_type = "recom"%}
				{%/if%}

				{%*<!-- 满意答案 -->*%}
				{%* 注：通过问诊平台生成的答案都是满意回答，所以只要有chunyu_data就说明该问题是问诊平台生成的数据。目前问诊平台的需求是用户通过问诊平台提交的问题先不进入问答的问题库，当用户评价完医生的问诊后帮用户生成一条有满意答案的详情页面，不允许再任何人再追问追答。如果之后这个逻辑改动了，那前后端改动可大了。主要因为春雨医生的账号是一对多的关系，数据库无法建立对应关系导致 *%}
				{%include 'detail/part_resolved_ans.inc'
					show = $has_recommend
					_answer_info = $recommend_answer_info
					_type = $recom_type
				%}

				{%*<!-- 官方管理员编辑满意答案 -->*%}
				{%include 'detail/part_ans_box.inc'
					show = $is_resolved && $is_official_admin
					sendURL = '/userMgr/editAnswer'
					type = "4"
				%}

				{%*<!-- onebox -->*%}
				{%include 'detail/part_map_onebox.inc'%}
				
				{%*<!--学而思广告-->*%}
				{%if !empty($AdvertisementLeft.data) && $is_resolved%}
					{%$AdvertisementLeft.data%}
				{%/if%}

				{%*<!-- 为您推荐 此处是在大搜点过来，有满意回答才展现 -->*%}
				{%include 'detail/part_recommend_text.inc'
					 show = $is_resolved
				%}
				
				{%*<!-- 已解决的问题加“感兴趣内容”的广告
						2017-05-3 点睛
						如果新的接口中有数据，则将数据传过去
				 -->*%}
				{%$guess_ad_data =""%}
				{%$related_ad_data =""%}
				{%if !empty($busi_data) &&  !empty($busi_data.ads)%}
					{%*<!--感兴趣的 数据-->*%}
					{%if !empty($busi_data.ads.position_g)%}
						{%$guess_ad_data = $busi_data.ads.position_g%}
					{%/if%}
					{%*<!--相关问题 数据-->*%}
					{%if !empty($busi_data.ads.position_rq)%}
						{%$related_ad_data = $busi_data.ads.position_rq[0]%}
					{%/if%}
					
				{%/if%}

				{%*<!-- 已经有满意回答的时候相关问题和搜索和同城问题显示在上面 -->*%}
				{%*<!--相关问题 已解决的第一条数据是广告-->*%}
				{%include 'detail/part_related_question.inc'
					 show = !empty($relate.result) && $is_resolved
					 related = $related_ad_data
				%}
				

				{%*<!--感兴趣的内容 广告 已解决的-->*%}
				{%include 'detail/part_guess_ad.inc'
					 show = $is_resolved
					 adData = $guess_ad_data
				%}
				
				{%include 'detail/part_related_search.inc'
					show = $is_resolved
				%}

				{%* 同城问题 *%}
				{%if $is_resolved%}
					<div class="mod-related-city js-related-city"></div>
				{%/if%}

				{%*<!-- 我的回答 -->*%}
				{%include 'detail/part_my_ans.inc'
				    show = $has_myAnswer
				%}

				{%*<!-- 其他回答 -->*%}
				{%include 'detail/part_other_ans.inc'
					show = !empty($answer_info.answer_list)
					cont_item = $my_answer
				%}

				{%*<!--学而思广告-->*%}
				{%if !empty($AdvertisementLeft.data) && !$is_resolved%}
					{%$AdvertisementLeft.data%}
				{%/if%}


				{%include 'detail/part_related_question.inc'
					 show = !empty($relate.result) && !$is_resolved
				%}

				{%include 'detail/part_related_search.inc'
					show = !$is_resolved
				%}

				{%*<!-- 只有待解决的时候才能够展示 -->*%}
				{%include 'detail/moudle/share.inc'
					show = !$is_resolved
				%}

				{%*<!-- 一对一功能暂时封闭 -->*%}
				{%**include 'detail/moudle/360_safe_expert.inc'**%}
				{%*<!-- 猜你喜欢大搜导流 -->*%}
				{%include 'detail/part_ad_bot_text.inc'
					show = $is_resolved
				%}

				{%*<!-- 2015-12-18 商业化图片广告 左侧 --> 1 qcms广告 2 js广告*%}
				{%if $show_bannerAd == 1 %}
					{%include 'cms/config/ad_detail_bottom_banner.php'%}
				{%/if%}
				{%if $show_bannerAd == 2 %}
				{%*<!--
					说明：此处是ajax请求广告，只放了一个外壳，css和js分别引用在相应的block中，通过js获取广告并插入到此处，css文件为：/resource/css/module/business/business_list.css js文件为 /resource/js/module/business/business_list.js
				-->*%}
					<div class="bussiness-ajax-detail js-bussiness-list" curPosition="detail"></div>
				{%/if%}
			</div>

			{%*<!-- 右侧侧边栏 -->*%}
			<div id="js-aside" class="aside">
				{%include 'detail/part_aside.inc'%}
			</div>
		</div>
	{%/if%}


{%**供搜索使用**%}
<div id="search_level" style="display:none">{%$ask_info.search_level%}</div>
{%/block%}



{**一些隐藏浮层**}
{%block 'other_bd'%}
	<div class="js-panels">

		{%include 'mod/common/bottom_ask_box.inc'%}

		{%include 'detail/moudle/lift_crumbs.inc'%}

		{%include 'detail/hidepages/add_reward.inc'
			show = $is_myAsk
		%}

		{%include 'detail/hidepages/question_abnormal.inc'
			show = $is_AskAuditOrDel
		%}

		{%include 'detail/hidepages/ans_success.inc'
			show = $can_be_ans || $is_official_admin
		%}

		{%include 'detail/hidepages/add_ask_ans_box.inc'%}

		{%include 'detail/hidepages/set_best_ans.inc'
			show = $ask_info.is_my_ask && !$has_best
		%}

		{%include 'detail/hidepages/daily_ans.inc'%}

		{%include 'detail/hidepages/usercard.inc'%}

		{%include 'cms/common/right_float_detail.inc'%}
		{%*<!--红包弹层-->*%}
		{%include 'detail/hidepages/redpackge_panel.inc'%}
		

		{%block 'task'%}
			{%include 'common/inc/task_panel.inc'%}
		{%/block%}
	</div>

{%/block%}
{%/strip%}
