require 'forwardable'
require 'lcsort'

class SirsiHolding
  extend Forwardable

  delegate [:dewey?, :valid_lc?] => :call_number

  BUSINESS_SHELBY_LOCS = %w[NEWS-STKS].freeze
  CLOSED_LIBS = %w[BIOLOGY CHEMCHMENG MATH-CS].freeze
  ECALLNUM = 'INTERNET RESOURCE'.freeze
  GOV_DOCS_LOCS = %w[BRIT-DOCS CALIF-DOCS FED-DOCS INTL-DOCS SSRC-DOCS SSRC-FICHE SSRC-NWDOC].freeze
  LOST_OR_MISSING_LOCS = %w[ASSMD-LOST LOST-ASSUM LOST-CLAIM LOST-PAID MISSING].freeze
  SHELBY_LOCS = %w[BUS-PER BUSDISPLAY BUS-MAKENA SHELBYTITL SHELBYSER STORBYTITL].freeze
  SKIPPED_CALL_NUMS = ['NO CALL NUMBER'].freeze
  SKIPPED_LOCS = %w[3FL-REF-S BASECALNUM BENDER-S CDPSHADOW DISCARD DISCARD-NS EAL-TEMP-S
                    E-INPROC-S E-ORDER-S E-REQST-S FED-DOCS-S LOCKSS LOST MAPCASES-S MAPFILE-S
                    MISS-INPRO MEDIA-MTXO NEG-PURCH SEL-NOTIF SHADOW SPECA-S SPECAX-S SPECB-S
                    SPECBX-S SPECM-S SPECMED-S SPECMEDX-S SPECMX-S SSRC-FIC-S SSRC-SLS STAFSHADOW
                    TECHSHADOW TECH-UNIQ WEST-7B SUPERSEDE WITHDRAWN].freeze
  TEMP_CALLNUM_PREFIX = 'XX'.freeze

  attr_reader :call_number, :current_location, :home_location, :library, :scheme, :type
  def initialize(call_number: '', current_location: '', home_location: '', library: '', scheme: '', type: '')
    @call_number = CallNumber.new(call_number)
    @current_location = current_location
    @home_location = home_location
    @library = library
    @scheme = scheme
    @type = type
  end

  def skipped?
    ([home_location, current_location] & SKIPPED_LOCS).any? ||
      type == 'EDI-REMOVE' ||
      physics_not_temp? ||
      CLOSED_LIBS.include?(library)
  end

  def shelved_by_location?
    if library == 'BUSINESS'
      ([home_location, current_location] & BUSINESS_SHELBY_LOCS).any?
    else
      ([home_location, current_location] & SHELBY_LOCS).any?
    end
  end

  def call_number_type
    case scheme
    when /^LC/
      'LC'
    when /^DEWEY/
      'DEWEY'
    when 'SUDOC'
      'SUDOC'
    when 'ALPHANUM'
      'ALPHANUM'
    else
      'OTHER'
    end
  end

  def bad_lc_lane_call_number?
    return false if valid_lc?
    return false if library != 'LANE-MED'
    return false if dewey?
    call_number_type == 'LC'
  end

  def ignored_call_number?
    SKIPPED_CALL_NUMS.include?(call_number) ||
      e_call_number? ||
      temp_call_number?
  end

  def temp_call_number?
    return false if library == 'HV-ARCHIVE' # Call numbers in HV-ARCHIVE are not temporary

    call_number.to_s.start_with?(TEMP_CALLNUM_PREFIX)
  end

  def e_call_number?
    call_number.to_s.start_with?(ECALLNUM)
  end

  def lost_or_missing?
    ([home_location, current_location] & LOST_OR_MISSING_LOCS).any?
  end

  def gov_doc_loc?
    ([home_location, current_location] & GOV_DOCS_LOCS).any?
  end

  def lopped_callnumber(is_serial = false)
  #   /**
  #    * return the call number with the volume part (if it exists) lopped off the
  #    *   end of it.
  #    * @param fullCallnum
  #    * @param callnumType - the call number type (e.g. LC, DEWEY, SUDOC)
  #    * @param isSerial - true if the call number is for a serial, false o.w.
  #    * @return the lopped call number
  #    */
  #   static String getLoppedCallnum(String fullCallnum, CallNumberType callnumType, boolean isSerial)
  #   {
  lopped_callnum = call_number.to_s
  if call_number_type == 'LC'
    match = call_number.to_s.match(Lcsort::LC)
    alpha, num, dec, doon1, c1alpha, c1num, doon2, c2alpha, c2num, c3alpha, c3num, extra = match.captures
    arr = []

    if num && dec
      arr << "#{alpha}#{num}.#{dec}"
    else
      arr << "#{alpha}#{num}"
    end
    arr << "#{doon1}" if doon1 && (!is_serial || c1alpha)
    arr << ".#{c1alpha}#{c1num}" if c1alpha
    arr << "#{doon2}" if doon2 && (!is_serial || c2alpha)
    arr << "#{c2alpha}#{c2num}" if c2alpha
    arr << "#{c3alpha}#{c3num}" if c3alpha
    if !is_serial && extra
      year_suffix = extra[/^\s*\d+/]
      arr << "#{year_suffix.strip}" unless year_suffix.nil?
    end

    arr.join(' ')
  elsif call_number_type == 'DEWEY'
            # removeDeweyVolSuffix(lopped_callnum)
            cut_suffix = getDeweyCutterSuffix(lopped_callnum) # == ??? 👇 lots o stuff 👇
              if lopped_callnum == nil || lopped_callnum.length == 0
                cut_suffix = nil
              end

              result = nil
              cutter = getDeweyCutter(lopped_callnum);
              # 🔪 in getDeweyCutter 🔪
              result = null
              #
              #     // dewey cutters can have trailing letters, preceded by a space or not
              #     String regex1 = DEWEY_CLASS_REGEX +  " *\\.?(" + DEWEY_CUTTER_TRAILING_LETTERS_REGEX + ")( +" + NOT_CUTTER + ".*)";
              #     String regex2 = DEWEY_CLASS_REGEX +  " *\\.?(" + DEWEY_MIN_CUTTER_REGEX + ")( +" + NOT_CUTTER + ".*)";
              #     String regex3 = DEWEY_CLASS_REGEX +  " *\\.?(" + DEWEY_CUTTER_SPACE_TRAILING_LETTERS_REGEX + ")( +" + NOT_CUTTER + ".*)";
              #     String regex4 = DEWEY_CLASS_REGEX +  " *\\.?(" + DEWEY_CUTTER_TRAILING_LETTERS_REGEX + ")(.*)";
              #     String regex5 = DEWEY_CLASS_REGEX +  " *\\.?(" + DEWEY_MIN_CUTTER_REGEX + ")(.*)";
              #     String regex6 = DEWEY_CLASS_REGEX +  " *\\.?(" + DEWEY_CUTTER_SPACE_TRAILING_LETTERS_REGEX + ")(.*)";
              #     Pattern pat1 = Pattern.compile(regex1);
              #     Pattern pat2 = Pattern.compile(regex2);
              #     Pattern pat3 = Pattern.compile(regex3);
              #     Pattern pat4 = Pattern.compile(regex4);
              #     Pattern pat5 = Pattern.compile(regex5);
              #     Pattern pat6 = Pattern.compile(regex6);
              #
              #     Matcher matcher = pat1.matcher(rawCallnum);
              #     if (!matcher.find()) {
              #         matcher = pat2.matcher(rawCallnum);
              #         if (!matcher.find()) {
              #             matcher = pat3.matcher(rawCallnum);
              #         }
              #     }
              #
              #     if (matcher.find()) {
              #         String cutter = matcher.group(2);
              #         String suffix = matcher.group(3);
              #         if (suffix.length() == 0)
              #             result = cutter.trim();
              #         else {
              #             // check if there are letters in the cutter that should be assigned
              #             //  to the suffix
              #             if (suffix.startsWith(" ") || cutter.endsWith(" "))
              #                 result = cutter.trim();
              #             else {
              #                 int ix = cutter.lastIndexOf(' ');
              #                 if (ix != -1)
              #                     result = cutter.substring(0, ix);
              #                 else
              #                     result = cutter.trim();
              #             }
              #         }
              #     }
              #     else {
              #         matcher = pat4.matcher(rawCallnum);
              #         if (matcher.find())
              #             result = matcher.group(2);
              #         else {
              #             matcher = pat5.matcher(rawCallnum);
              #             if (matcher.find())
              #                 result = matcher.group(2);
              #             else {
              #                 matcher = pat6.matcher(rawCallnum);
              #                 if (matcher.find())
              #                     result = matcher.group(2);
              #             }
              #         }
              #     }
              #     if (result != null)
              #         return result.trim();
              #     return result;
              # }
              # 🔪 END getDeweyCutter 🔪

            # 👇 BACK in gewDeweyCutterSuffix 👇
            #     if (cutter != null) {
            #         int ix = rawCallnum.indexOf(cutter) + cutter.length();
            #         result = rawCallnum.substring(ix).trim();
            #     }
            #
            #     if (result == null || result.length() == 0)
            #     {
            #         // dewey cutters can have trailing letters, preceded by a space or not
            #         String regex1 = DEWEY_CLASS_REGEX +  " *\\.?(" + DEWEY_CUTTER_TRAILING_LETTERS_REGEX + ")( +" + NOT_CUTTER + ".*)";
            #         String regex2 = DEWEY_CLASS_REGEX +  " *\\.?(" + DEWEY_MIN_CUTTER_REGEX + ")( +" + NOT_CUTTER + ".*)";
            #         String regex3 = DEWEY_CLASS_REGEX +  " *\\.?(" + DEWEY_CUTTER_SPACE_TRAILING_LETTERS_REGEX + ")( +" + NOT_CUTTER + ".*)";
            #         String regex4 = DEWEY_CLASS_REGEX +  " *\\.?(" + DEWEY_CUTTER_TRAILING_LETTERS_REGEX + ")(.*)";
            #         String regex5 = DEWEY_CLASS_REGEX +  " *\\.?(" + DEWEY_MIN_CUTTER_REGEX + ")(.*)";
            #         String regex6 = DEWEY_CLASS_REGEX +  " *\\.?(" + DEWEY_CUTTER_SPACE_TRAILING_LETTERS_REGEX + ")(.*)";
            #         Pattern pat1 = Pattern.compile(regex1);
            #         Pattern pat2 = Pattern.compile(regex2);
            #         Pattern pat3 = Pattern.compile(regex3);
            #         Pattern pat4 = Pattern.compile(regex4);
            #         Pattern pat5 = Pattern.compile(regex5);
            #         Pattern pat6 = Pattern.compile(regex6);
            #
            #         Matcher matcher = pat1.matcher(rawCallnum);
            #         if (!matcher.find()) {
            #             matcher = pat2.matcher(rawCallnum);
            #             if (!matcher.find()) {
            #                 matcher = pat3.matcher(rawCallnum);
            #                 if (!matcher.find()) {
            #                     matcher = pat4.matcher(rawCallnum);
            #                     if (!matcher.find()) {
            #                         matcher = pat5.matcher(rawCallnum);
            #                         if (!matcher.find()) {
            #                             matcher = pat6.matcher(rawCallnum);
            #                         }
            #                     }
            #                 }
            #             }
            #         }
            #
            #         if (matcher.find(0)) {
            #             cutter = matcher.group(2);
            #             String suffix = matcher.group(3);
            #             if (suffix.trim().length() > 0) {
            #                 // check if there are letters in the cutter that should be assigned
            #                 //  to the suffix
            #                 if (suffix.startsWith(" ") || cutter.endsWith(" "))
            #                     result = suffix;
            #                 else {
            #                     int ix = cutter.lastIndexOf(' ');
            #                     if (ix != -1)
            #                         result = cutter.substring(ix) + suffix;
            #                     else
            #                         result = suffix;
            #                 }
            #             }
            #         }
            #     }
            #     if (result != null)
            #         result = result.trim();
            #     if (result == null || result.trim().length() == 0)
            #         return null;
            #     else
            #         return result;
            # } ☝️ END of getDeweyCutterSuffix ☝️


            # ✋ back in removeDeweyVolSuffix land ✋ #
            if cut_suffix == nil || cut_suffix.length == 0
              return lopped_callnum
            end

            # VOL_PATTERN = Pattern.compile(PUNCT_PREFIX + NS_PREFIX + VOL_LETTERS + "\\.? ?" + VOL_NUMBERS, Pattern.CASE_INSENSITIVE);
            # VOL_LOOSE_PATTERN = Pattern.compile(PUNCT_PREFIX + NS_PREFIX + VOL_LETTERS + "\\.? ?" + VOL_NUMBERS_LOOSER, Pattern.CASE_INSENSITIVE)
            # VOL_LETTERS_PATTERN = Pattern.compile(PUNCT_PREFIX + NS_PREFIX + VOL_LETTERS + "[\\/\\. ]" + VOL_NUM_AS_LETTERS , Pattern.CASE_INSENSITIVE)
            # String ADDL_VOL_REGEX = "[\\:\\/]?(box|carton|fig|flat box|grade|half box|half carton|index|large folder|large map folder|map folder|mfilm|mfiche|os box|os folder|pl|reel|sheet|small folder|small map folder|suppl|tube|series)"
            # Pattern ADDL_VOL_PATTERN = Pattern.compile(ADDL_VOL_REGEX + ".*", Pattern.CASE_INSENSITIVE)
            # PUNCT_PREFIX = "([\\.:\\/\\(])?"
          	# NS_PREFIX = "(n\\.s\\.?\\,? ?)?"
            # VOL_LETTERS = "[\\:\\/]?(bd|ed|hov|iss|issue|jahrg|new ser|no|part|pts?|ser|shanah|[^a-z]t|v|vols?|vyp" + "|" + MONTHS + ")"
            # VOL_NUMBERS = "\\d+([\\/-]\\d+)?( \\d{4}([\\/-]\\d{4})?)?( ?suppl\\.?)?"
            # VOL_NUMBERS_LOOSER = "\\d+.*"
          	# VOL_NUM_AS_LETTERS = "[A-Z]([\\/-]\\[A-Z]+)?.*"

            #
            # Matcher matcher = VOL_PATTERN.matcher(cutSuffix);
            # if (!matcher.find())
            # {
            #   matcher = VOL_LOOSE_PATTERN.matcher(cutSuffix);
            #   if (!matcher.find())
            #   {
            #     matcher = VOL_LETTERS_PATTERN.matcher(cutSuffix);
            #     if (!matcher.find())
            #       matcher = ADDL_VOL_PATTERN.matcher(cutSuffix);
            #   }
            # }
            #
            # if (matcher.find(0))
            # {
            #   // return orig call number with matcher part lopped off.
            #   int ix = rawDeweyCallnum.indexOf(cutSuffix) + matcher.start();
            #   if (ix != -1 && ix < rawDeweyCallnum.length())
            #     lopped = rawDeweyCallnum.substring(0, ix).trim();
            # }
            #
            # lopped = removeLooseMonthSuffix(lopped);
            #
            # if lopped.equals(rawDeweyCallnum)
            #   lopped = removeAddlVolSuffix(rawDeweyCallnum)
            # end

            if lopped.end_with?(':') || lopped.end_with?('(')
              lopped[0, lopped.length-1]
            else
              lopped
            end
            # TODO: DO SOMETHING WITH SERIAL LOPPING
      else
  # //TODO: needs to be longest common prefix
        if is_serial
          lopped = nil #edu.stanford.CallNumUtils.removeNonLCDeweySerialVolSuffix(fullCallnum, callnumType);
        else
          lopped = nil # edu.stanford.CallNumUtils.removeNonLCDeweyVolSuffix(fullCallnum, callnumType);
        end
    end
  end

  private

  def physics_not_temp?
    library == 'PHYSICS' && ![home_location, current_location].include?('PHYSTEMP')
  end

  class CallNumber
    BEGIN_CUTTER_REGEX = /( +|(\.[A-Z])| *\/)/
    VALID_DEWEY_REGEX = /^\d{1,3}(\.\d+)? *\.?[A-Z]\d{1,3} *[A-Z]*+.*/
    VALID_LC_REGEX = /(^[A-Z&&[^IOWXY]]{1}[A-Z]{0,2} *\d+(\.\d+)?( +([\da-z]\w*)|(^[A-Z]\D+[\w]*))?) *\.?[A-Z]\d+.*/

    attr_reader :call_number
    def initialize(call_number)
      @call_number = call_number
    end

    def to_s
      call_number
    end

    def dewey?
      call_number.match?(VALID_DEWEY_REGEX)
    end

    def valid_lc?
      call_number.match?(VALID_LC_REGEX)
    end

    def with_leading_zeros
      raise ArgumentError unless dewey?

      decimal_index = before_cutter.index('.') || 0
      call_number_class = if decimal_index > 0
                            call_number[0, decimal_index].strip
                          else
                            before_cutter
                          end

      case call_number_class.length
      when 1
        "00#{call_number}"
      when 2
        "0#{call_number}"
      else
        call_number
      end
    end

    def normalized_lc
      call_number.gsub(/\s\s+/, ' ') # change all multiple whitespace chars to a single space
                 .gsub(/\s?\.\s?/, '.') # remove a space before or after a period
                 .gsub(/^([A-Z][A-Z]?[A-Z]?) ([0-9])/, "\1\2") # remove space between class letters and digits
    end

    def before_cutter
      (call_number.split(BEGIN_CUTTER_REGEX).first || '').strip
    end
  end
end
