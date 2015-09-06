# -*- coding: utf-8 -*-
require 'logger'
require 'pathname'
require 'json'
require 'open-uri'
require 'yaml'

module RankForce
  module Utils
    class << self
      def file?(e)
        !!(FileTest.exist?(e) rescue nil)
      end

      def directory?(e)
        !!(FileTest::directory?(e) rescue nil)
      end

      def create_path(*args)
        Pathname.new(args.join("/")).cleanpath.to_s.encode(Utils.os_encoding)
      end

      def create_dir(*args)
        Dir::mkdir(create_path(args)) rescue nil
      end

      def load(path)
        symbolize_keys(YAML.load_file(path))
      end

      def os_encoding
        RUBY_PLATFORM.downcase =~ /mswin(?!ce)|mingw|cygwin|bccwin/ ?
          "CP932" : "UTF-8"
      end

      def valiable_set(elem, params)
        params.each {|k, v| elem.instance_variable_set("@#{k.to_s}", v)}
      end

      private
      def symbolize_keys(o)
        case o
        when Array
          o.map {|elem| symbolize_keys elem}
        when Hash
          Hash[
            o.map {|key, value|
              k = key.is_a?(String) ? key.to_sym : key
              v = symbolize_keys value
              [k,v]
            }]
        else
          o
        end
      end
    end
  end

  class ShortURL
    BITLY_URL = "http://api.bit.ly/v3/shorten"
    TINY_URL = 'http://tinyurl.com/api-create.php'
    DEDAULT_API = "bitly"

    def initialize(opt = {})
      @opt = opt
      @opt.merge!({:api => DEDAULT_API}) if @opt[:api].nil?
    end

    def conv(url)
      self.send(@opt[:api], url)
    end

    private
    def bitly(url)
      @opt.merge!({:longUrl => url, :format => "json"})
      api_url = @opt.to_q(BITLY_URL)
      open(api_url) do |f|
        json = JSON.parse(f.read)
        json["data"]["url"] if json["status_code"] == 200
      end
    end

    def tinyurl(url)
      @opt.merge!({:url => url})
      api_url = @opt.to_q(TINY_URL)
      open(api_url) {|f| f.read}
    end
  end

  class Log
    def initialize(path, debug_on)
      @debug = {}
      @debug_on = debug_on
      if Utils.directory? path
        level = [0, 1, 2, 3, 4].index(LOG_LEVEL) || Logger::DEBUG
        @log = Logger.new(logfile(path))
        @log.level = level
      else
        unless path.nil?
          @debug["error"] = []
          @debug["error"] << "Invalid log directory path - #{path}"
        end
      end
    end

    def logfile(dir)
      Pathname.new(dir + "/" + "#{Time.now.strftime("%Y%m%d")}.log").cleanpath
    end

    def write(name, *args)
      # ログ出力処理、デバッグスタックに保存
      if name =~ /=$/
        name.chop!
        @debug[name] = [] unless @debug[name].instance_of?(Array)
        args[0].each do |msg|
          @log.send(name, msg.force_encoding(Utils.os_encoding)) unless @log.nil?
          @debug[name] << msg
        end
      end
    end

    def debug(name)
      # 最新のデバッグメッセージを標準出力
      if name == 'print'
        if @debug[@name].instance_of?(Array) && @debug_on
          puts "#{@debug[@name].last}\n"
        end
      # デバッグメッセージをすべて標準出力
      elsif name == 'dump'
        if @debug[@name].instance_of?(Array) && @debug_on
          @debug[@name].each do |msg|
            puts "#{msg}\n"
          end
        end
      else
         # ログメソッドを保存
        @name = name
        self
      end
    end

    def method_missing(name, *args)
      attr = name.to_s
      write(attr, args)
      debug(attr)
    end
  end

  module Mapper
    class << self
      def to_en(str)
        en[ja.index(str)]
      end

      def to_ja(str)
        ja[en.index(str)]
      end

      private
      def en
        %w[bizplus newsplus lifeline wildplus moeplus mnewsplus femnewsplus dqnplus
        scienceplus owabiplus liveplus news trafficinfo musicnews comicnews gamenews pcnews
        news7 archives news2 asia bakanews editorial wikileaks kokusai war news4plus
        news5 iraq africa europa news5plus dejima entrance entrance2 qa pcqa
        goods gline event 2chse dataroom vote operate operatex sec2ch sec2chd saku2ch
        saku sakud sakukb intro honobono yume offmatrix offreg offevent aasaloon
        mona nida aastory kao mass youth disaster 119 gender giin manifesto police
        court saibanin soc atom river traf way develop recruit job volunteer welfare
        mayor ftax jsdf nenga lifework regulate manage management estate koumu
        shikaku lic haken hoken tax exam hosp bio hikari dtp part koukoku
        agri build industry peko expo subcal bun mitemite poem rongo movie
        cinema rmovie kinema occult esp sfx rsfx drama siki fortune uranai
        kyoto gallery rakugo ruins emperor rikei sci life bake kikai denki
        robot infosys informatics sim nougaku sky galileo doctor kampo math
        doboku material space future wild earth psycho gengo dialect pedagogy sociology
        economics book poetics history history2 whis archeology min kobun english
        usa korea china taiwan geo chiri gogaku art philo jurisp shihou kaden
        wm vcamera bakery toilet sony apple2 phs keitai iPhone smartphone chakumelo
        appli dgoods camera dcamera av pav battery seiji diplomacy trafficpolicy eco
        stock stockb market livemarket1 livemarket2 deal koumei kyousan sisou kova
        money food candy juice pot cook okome yasai kinoko salt ramen nissin
        jnoodle sushi don curry bread pasta kbbq konamono toba gurume famires
        jfoods bento sake wine drunk recipe patissier supplement lifesaloon kankon
        okiraku homealone countrylife debt inpatient sportsclub bath anniversary sousai
        baby kagu diy shop hcenter used rental trend ticketplus model fashion
        underwear shoes female diet mensbeauty aroma seikei shapeup world northa
        credit point cafe30 cafe40 cafe50 cafe60 live souji goki kechi2 chance
        cigaret megane yuusen conv sale stationery class shar x3 denpa owarai
        2chbook uwasa charaneta charaneta2 mascot senji lovesaloon ex x1 gaysaloon
        nohodame dame loser hikky mental single wom sfe wmotenai ms male
        motetai motenai alone tomorrow employee campus student otaku nendai sepia
        gag 575 tanka hidari bbylive tv2chwiki livesaturn livevenus livejupiter liveuranus
        endless weekly livewkwest livenhk liveetv liventv livetbs livecx liveanb livetx
        livebs livewowow liveskyp liveradio liveanime kokkai dome livebase livefoot
        oonna ootoko dancesite festival jasmine edu jsaloon kouri juku ojyuken
        senmon design musicology govexam hobby magic card puzzle craft toy
        zoid watch smoking knife doll engei dog pet aquarium goldenfish insect
        cat bike car kcar auto usedcar truck army radio train rail jnr
        ice gage bus airline mokei radiocontrol gun fireworks warhis chinahero sengoku
        nanminhis dance bird collect photo sposaloon sports rsports stadium athletics
        gymnastics muscle noroma wsports ski skate swim msports boat birdman fish
        bass bicycle equestrian f1 olympic bullseye parksports amespo cheerleading xsports
        base npb meikyu mlb hsb kyozin soccer eleven wc football basket tennis
        volley ovalball pingpong gutter golf billiards ballgame k1 wres budou
        boxing sumou jyudo oversea 21oversea travel hotel localfoods tropical onsen
        park zoo museum out tvsaloon kouhaku tv natsutv tvd nhkdrama natsudora
        kin am rradio tv2 cs skyp bs nhk cm geino celebrity 4sama kyon2
        actor actress geinoj geinin ana ami apple ainotane zurui mendol idol
        akb ske jan smap jr jr2 mj pachi pachij pachik slot slotj slotk
        keiba uma keirin kyotei autorace loto gsaloon gameover goveract goverrpg
        gamerpg ff gamesrpg gamerobo gal gboy ggirl gamespo gamehis otoge gamefight
        gamestg gamef fly famicom zgame retro retro2 game90 arc rarc amusement
        gecen game gameama gameswf cgame tcg bgame gamestones quiz ghard gameurawaza
        gamechara gamemusic handygame handygover handygrpg poke wifi rhandyg pokechara
        mmonews mmoqa ogame ogame2 ogame3 mmosaloon netgame mmo mmominor asaloon
        anime4vip anime anime2 anime3 ranime ranimeh animovie anichara anichara2 cosp
        voice voiceactor doujin comiket csaloon comic rcomic ymag wcomic gcomic
        4koma cchara sakura eva cartoon iga bookall magazin mystery sf litechara
        zassi books ebooks ehon juvenile illustrator msaloon mjsaloon musicj musicjm
        musicjf musicjg natsumeloj enka mesaloon musice natsumeloe music beatles visual
        visualb dj disco randb punk hrhm hiphop techno progre healmusic wmusic
        reggae classic fusion classical contemporary nika suisou chorus doyo asong
        soundtrack karaok legend minor band compose piano healing jinsei psy
        body stretch handicap cancer nanbyou infection hiv atopi allergy hage
        pure furin gay utu break pc2nanmin win jobs mac os desktop pc
        notepc jisaku printer hard cdr software mobile bsoft unix db linux
        prog tech cg dtm avi swf gamedev i4004 internet hp affiliate hosting
        mysv php hack sec network ipv6 friend isp netspot nifty google mmag
        nanmin ad esite streaming mstreaming mdis netradio blog sns net yahoo
        nntp bobby lobby maru mog2 mukashi kitchen tubo joke shugi rights accuse
        morningcoffee ranking record siberia news4vip news4viptasu poverty heaven4vip
        neet4vip aniki]
      end

      def ja
        %w[ビジネスnews+ ニュース速報+ 緊急自然災害 ニュース二軍+ 萌えニュース+ 芸スポ速報+
        ほのぼのnews+ 痛いニュース+ 科学ニュース+ お詫び+ ニュース実況+ ニュース速報 交通情報
        芸能音楽速報 アニメ漫画速報 ゲーム速報 PCニュース 私のニュース 懐かしニュース ニュース議論
        ニュース極東 バカニュース 社説 WikiLeaks 国際情勢 戦争・国防 東アジアnews+ イスラム情勢
        イラク情勢 アフリカ情勢 欧州・CIS情勢 ニュース国際+ dejima ラウンジ ﾗｳﾝｼﾞｸﾗｼｯｸ
        初心者の質問 PC初心者 グッズリスト ガイドライン イベント企画 2ch証券取引所 資料室
        投票所 2ch運用情報 運用情報臨時 2ch規制情報 2ch規制議論 削除要請 削除整理 削除議論
        削除知恵袋 自己紹介 ほのぼの 夢・独り言 大規模OFF 定期OFF 突発OFF AAサロン
        モナー ニダー AA長編 顔文字 マスコミ 少年犯罪 自然災害 消防救急防災 男性論女性論
        議員・選挙 政治家語録 警察 裁判・司法 裁判員制度 社会・世評 環境・電力 河川・ダム等
        運輸・交通 道路・高速道路 都市計画 就職 転職 ボランティア 介護・福祉 地方自治知事 ふるさと納税
        自衛隊 郵便・郵政 生涯学習 通信行政 経営学 店舗運営 賃貸不動産 公務員 法律勉強相談
        資格全般 派遣業界 保険業界 税金経理会計 会計全般試験 病院・医者 医療業界 光通信
        DTP・印刷 アルバイト 広告業界 農林水産業 建設住宅業界 製造業界 食品業界・問題 万博・地方博
        サブカル 創作文芸 創作発表 詩・ポエム 名言・格言 映画一般・8mm 映画作品・人 懐かし邦画
        懐かし洋画 オカルト 超能力 特撮！ 昭和特撮 演劇・舞台役者 宝塚・四季 占い 占術理論実践
        神社・仏閣 美術鑑賞 伝統芸能 世界遺産 皇室・王侯貴族 理系全般 物理 生物 化学
        機械・工学 電気・電子 ロボット技術 情報システム 情報学 シミュレート 農学 天文・気象
        宇宙 医歯薬看護 東洋医学 数学 土木・建築 材料物性 航空・船舶 未来技術 野生生物
        地球科学 心理学 言語学 方言 教育学 社会学 経済学 文学 詩文学 日本史
        日本近代史 世界史 考古学 民俗・神話学 古文・漢文 ENGLISH アメリカ ハングル
        中国 台湾 地理・人類学 地理お国自慢 外国語 芸術デザイン 哲学 法学 司法試験
        家電製品 ポータブルAV ビデオカメラ 調理家電 シャワートイレ ソニー Apple 携帯・ＰＨＳ
        携帯機種 iPhone スマートフォン 携帯コンテンツ 携帯電話ゲー デジタルモノ カメラ
        デジカメ AV機器 ピュアAU 電池等 政治 外交政策 交通政策 経済 株式
        株個別銘柄 投資一般 市況1 市況2 先物 創価・公明 共産党 政治思想 ゴーマニズム
        金融 食べ物 お菓子 ソフトドリンク お茶・珈琲 料理 米・米加工品 野菜・果物 きのこ
        調味料 ラーメン インスタント麺 そば・うどん おすし 丼 カレー パン パスタ・ピザ
        焼肉 たこ焼き等 珍味 グルメ外食 ファミレス Ｂ級グルメ 弁当・駅弁 お酒・Bar ワイン
        居酒屋 レシピ 製菓・製パン 健康食・サプリ 生活サロン 生活全般 その日暮らし 一人暮らし
        田舎暮らし 借金生活 入院生活 スポーツクラブ お風呂・銭湯 記念日 冠婚葬祭 育児
        家具 DIY 通販・買い物 家電等量販店 中古リサイクル レンタル 流行 Walker+ モデル
        ファッション 下着 靴 化粧 美容 男の美容・化粧 香水芳香消臭 美容整形 ダイエット
        一般海外生活 北米海外生活 クレジット ポイント・マイル ３０代 ４０代 ５０代以上 ６０歳以上
        家庭 掃除全般 害虫害獣対策 ドケチ 懸賞 たばこ めがね マイライン コンビニ
        バーゲン 文房具 習い事 新シャア専用 旧シャア専用 電波・お花畑 お笑い小咄 同人ノウハウ
        噂話 キャラネタ なりきりネタ マスコットキャラ 戦時 恋愛サロン カップル ×１
        同性愛サロン のほほんダメ 無職・だめ 負け組 ヒッキー メンヘルサロン 独身貴族 女性
        独身女性限定 もてない女 既婚女性 独身男性 もてたい男 モテない男性 孤独な男性 既婚男性
        リーマン 大学生活 大学学部・研究 おたく 年代別 セピア 駄洒落 しりとり 五七五・短歌
        左利き 実況headline テレビ番組欄 なんでも実況S なんでも実況V なんでも実況J なんでも実況U
        実況ch 番組ch 番組ch(西日本) 番組ch(NHK) 番組ch(教育) 番組ch(NTV) 番組ch(TBS)
        番組ch(フジ) 番組ch(朝日) 番組ch(TX) BS実況(NHK) BS実況(民放) スカパー実況
        ラジオ実況 アニメ特撮実況 議会選挙実況 スポーツch 野球ch サッカーch 五輪実況(女) 五輪実況(男)
        芸能ch お祭りch streaming実況 教育・先生 大学受験サロン 大学受験 学習塾・予備校
        お受験 専門学校 美術系学校 音楽系学校 公務員試験 趣味一般 手品・曲芸 トランプ パズル
        ハンドクラフト おもちゃ ゾイド 時計・小物 煙草銘柄・器具 刃物 お人形 園芸 犬猫大好き
        ペット大好き アクアリウム 日本の淡水魚 昆虫・節足動物 生き物苦手 バイク 車 軽自動車
        車種・メーカー 中古車 大型・特殊車両 軍事 無線 鉄道総合 鉄道路線・車両 鉄道懐かし
        鉄道(海外) 鉄道模型 バス・バス路線 エアライン 模型・プラモ RC（ラジコン) サバゲー
        花火 三国志・戦国 中国英雄 戦国時代 歴史難民 ダンス 野鳥観察 コレクション 写真撮影
        スポーツサロン スポーツ 懐かしスポーツ スポーツ施設 陸上競技 体操・新体操 ウエイトトレ 運動音痴
        冬スポーツ スキースノボ スケート 水泳 マリンスポーツ 船スポーツ 空スポーツ 釣り
        バス釣り 自転車 乗馬・馬術 ﾓｰﾀｰｽﾎﾟｰﾂ オリンピック 的スポーツ 公園スポーツ アメスポ
        チア xsports プロ野球 球界改革議論 野球殿堂 野球総合 高校野球 アンチ球団 国内サッカー
        日本代表蹴球 ワールドカップ 海外サッカー バスケット テニス バレーボール ラグビー 卓球
        ボウリング ゴルフ ビリヤード その他球技 格闘技 プロレス 武道・武芸 ボクシング 相撲
        伝統武術 海外旅行 危ない海外 国内旅行 ホテル･旅館 土産物・特産物 トロピカル 温泉
        遊園地 動物園・水族館 博物館・美術館 登山キャンプ テレビサロン 年末年始番組 テレビ番組 懐かしテレビ
        テレビドラマ 大河ドラマ 懐かしドラマ 時代劇 ラジオ番組 懐かしラジオ 海外テレビ ケーブル放送
        スカパー デジタル放送 NHK 広告・ＣＭ 芸能 海外芸能人 アジアエンタメ 懐かし芸能人
        男性俳優 女優 U-15タレント お笑い芸人 アナウンサー あみ＆あゆ 椎名林檎 モ娘（羊）
        モ娘（鳩） 男性アイドル 女性アイドル 地下アイドル ローカルアイドル ジャニーズ スマップ
        ジャニーズ２ ジャニーズJr 麻雀・他 パチンコサロン パチンコ店情報 パチンコ機種等 スロットサロン
        スロット店情報 スロット機種 競馬 競馬２ 競輪 競艇 オートレース 宝くじ ゲームサロン
        家ゲー攻略 家ゲACT攻略 家ゲRPG攻略 家ゲーRPG FF・ドラクエ 家ゲーSRPG ロボットゲー
        ギャルゲー 女向ゲー大人 女向ゲー一般 スポーツ・RACE 歴史ゲーム 音ゲー 格闘ゲーム シューティング
        PCアクション フライトシム 家庭用ゲーム 家ゲーZ区分 レトロゲーム 家ゲーレトロ レトロ32bit以上
        アーケード アケゲーレトロ メダル・プライズ ゲーセン PCゲーム 同人ゲーム ブラウザゲーム 卓上ゲーム
        TCG 将棋・チェス 囲碁・オセロ クイズ雑学 ハード・業界 裏技・改造 ゲームキャラ ゲーム音楽
        携帯ゲーソフト 携帯ゲー攻略 携帯ゲーRPG ポケモン Wi-Fi 携帯ゲーレトロ 携帯ゲーキャラ
        ネトゲ速報 ネトゲ質問 ネトゲ実況 ネトゲ実況2 ネトゲ実況3 ネトゲサロン ネットゲーム 大規模MMO
        小規模MMO アニメサロン アニメサロンex アニメ アニメ２ アニメ新作情報 懐アニ昭和 懐アニ平成
        アニメ映画 アニキャラ総合 アニキャラ個別 コスプレ 声優総合 声優個人 同人 同人イベント
        漫画サロン 漫画 懐かし漫画 少年漫画 週刊少年漫画 少女漫画 ４コマ漫画 漫画キャラ CCさくら
        エヴァ 海外アニメ漫画 アニメ漫画業界 文芸書籍サロン ライトノベル ミステリー SF・FT・ホラー 文芸キャラ
        雑誌 一般書籍 電子書籍 絵本 児童書 イラストレーター 音楽サロン 邦楽サロン 邦楽
        邦楽男性ソロ 邦楽女性ソロ 邦楽グループ 懐メロ邦楽 演歌 洋楽サロン 洋楽 懐メロ洋楽
        音楽一般 ビートルズ ヴィジュサロン ヴィジュバンド ＤＪ・クラブ ディスコ R&B・SOUL パンク
        HR・HM HIPHOP TECHNO プログレ ヒーリング音楽 ワールド音楽 レゲエ ジャズ
        フュージョン クラシック 現代音楽 エレクトロニカ 吹奏楽 合唱 童謡・唱歌 アニソン等
        サントラ カラオケ 伝説の インディーズ バンド 楽器・作曲 鍵盤楽器 癒し 人生相談
        心と宗教 身体・健康 マッサージ等 ハンディキャップ 癌・腫瘍 難病 新型感染症 HIVサロン
        アトピー アレルギー ハゲ・ズラ 純情恋愛 不倫・浮気 同性愛 メンタルヘルス 失恋
        PCサロン Windows 旧・mac 新・mac OS デスクトップ パソコン一般 ノートPC
        自作PC プリンタ ハードウェア CD-R,DVD ソフトウェア モバイル ビジネスsoft UNIX
        データベース Linux プログラマー プログラム ＣＧ DTM DTV FLASH ゲ製作技術
        昔のPC インターネット Web制作 Web収入 レンタル鯖 自宅サーバ WebProg ネットワーク
        セキュリティ 通信技術 IPv6 ポスペ・irc プロバイダー ネットカフェ Nifty Google
        メルマガ 難民 宣伝掲示板 ネットサービス YouTube 携帯動画 音楽配信 ネットラジオ等
        ブログ ソーシャルネット ネットwatch オークション nntp おいらロビー ロビー ●
        なんでもあり 昔 厨房！ 最悪 学歴 主義・主張 人権問題 2ch批判要望 モ娘（狼）
        格付け 新記録・珍記録 シベリア超速報 ニュー速VIP ニュー速VIP+ ニュー速(嫌儲) 天国
        ニー速 ガチホモ]
      end
    end
  end
end

class Object
  def current_method
    $1 if /`(.*)'/ =~ caller.first
  end
end

class Hash
  def to_q(url = nil)
    qs = self.map {|k, v| "#{k.to_s}=#{v.to_s}"}.join("&")
    url.nil? ? qs : [url, qs].join("?")
  end
end

class String
  def nsplit(n)
    idx = 0
    splited = []
    while true
      str = self.slice(n * idx, n)
      unless str.nil?
        splited << str
        idx += 1
      else
        break
      end
    end
    splited
  end
end